require 'json'
module RestRails
  class DataController < ::ApplicationController
    include ApplicationHelper
    # skip_before_action :verify_authenticity_token, if: -> {self.respond_to?("verify_authenticity_token")}
    before_action :verify_table_permissions!, only: [:create, :update, :destroy, :attach, :unattach]
    before_action :set_model
    before_action :set_object, only: [:show, :update, :destroy, :fetch_column, :attach, :unattach]

    def index
      p_hash = index_params.to_h
      ppage = (params[:per_page] || 100).to_i
      page =  (params[:page] || 1).to_i
      off = (page-1) * ppage

      base_query = p_hash.blank? ? @model.all : @model.where(p_hash)

      @objects = base_query.order(:id).limit(ppage).offset(off)
      @objects = @objects.map{|x| standardize_json(x) }

      render json: {code: 200, objects: @objects, count: @objects.count, total: @model.count}
    end

    def show
      render json: {code: 200, object: standardize_json(@object)}
    end

    def create
      @object = @model.new(model_params)

      attach_files
      if @object.save
        render json: {code: 200, msg: "success", object: standardize_json(@object)}
      else
        render json: {code: 300, msg: "FAILED!"}
      end
    end

    def update
      attach_files
      if @object.update(model_params)
        render json: {code: 200, msg: "success", object: standardize_json(@object)}
      else
        render json: {code: 300, msg: "FAILED!"}
      end
    end

    def destroy
      if @object.destroy
        render json: {code: 200, msg: "success"}
      else
        render json: {code: 300, msg: "FAILED!"}
      end
    end

    def fetch_column
      raise RestRails::Error.new "Column '#{params[:column]}' does not exist for #{params[:table_name]} table!" unless columns_for(@object).include?(params[:column])

      col_value = @object.public_send(params[:column])
      render json: {code: 200, msg: "success", value: prepare_column(col_value)}
    end

    def attach
      # post   '/:table_name/:id/attach/:attachment_name' => 'data#attach'
      raise RestRails::Error.new "No Attached file!" unless params[:attachment].is_a?(ActionDispatch::Http::UploadedFile)
      raise RestRails::Error.new "Attachment '#{params[:attachment_name]}' does not exist for #{params[:table_name]} table!" unless attachments_for(@empty_obj).include?(params[:attachment_name].to_sym)

      @object.public_send(params[:attachment_name].to_sym).attach(params[:attachment])
      render json: {code: 200, msg: "success"}
    end

    def unattach
      # delete '/:table_name/:id/unattach/:attachment_id' => 'data#unattach'
      att = ActiveStorage::Attachment.find(params[:attachment_id])

      raise RestRails::Error.new "Unauthorized! Attachment does not belong to object!" unless (@object.id == att.record_id) && (@object.is_a? att.record_type.constantize)

      att.purge

      render json: {code: 200, msg: "success"}
    end

    private

    def set_model
      # /api/v1/:table_name/...
      # e.g. /api/v1/users  => User

      # Take the tablename, and make the Model of the relative table_name
      @model = model_for(params[:table_name])
      @empty_obj = @model.new
      p @empty_obj
    end

    def set_object
      # Take model from "set_model"
      @object = @model.find(params[:id])
    end

    def index_params
      mn = @model.model_name.singular.to_sym
      # {user: {name: "something", other_column_name: "somevalue"}}
      return {} if params[mn].blank?
      # MAKE LIST OF THINGS TO PERMIT:
      arr = @model.attribute_names.map(&:to_sym)

      # allow arrays for all columns for flexible where queries
      arr += arr.map do |attr|
        {attr=>[]}
      end
      params.require(mn).permit(arr)
    end

    def attach_files
      # BASED ON ACTIVE STORAGE
      mn = @model.model_name.singular.to_sym # /users => user
      #
      file_set = attachments_for(@empty_obj)
      file_set.each do |fs|
        next if params[mn].blank? || params[mn][fs].blank?
        attachment = params[mn][fs]

        if attachment.is_a?(ActionDispatch::Http::UploadedFile)
          @object.public_send(fs).attach(attachment)
        elsif attachment.is_a?(Array) && attachment.first.is_a?(ActionDispatch::Http::UploadedFile)
          @object.public_send(fs).attach(attachment)
        elsif attachment.is_a?(Array)
          params[mn][fs] = attachment.reject{|x| x.include?("/rails/active_storage/blobs")}
        elsif attachment.is_a? String
          params[mn][fs] = nil if attachment.include?("/rails/active_storage/blobs")
        end
      end
    end

    # ==========UNIVERSAL STRONG PARAMS SETUP=================
    def model_params
      mn = @model.model_name.singular.to_sym
      # {user: {name: "something", other_column_name: "somevalue"}}
      return {} if params[mn].blank? # to allow create for empty items

      # params.require(:table_name).permit(:column_name1, :column_name2, etc., array_type: [], array_type2: [])
      params.require(mn).permit(permitted_columns)
    end

    def permit_array?(attr)
      return false unless attr.is_a? Symbol
      permitable_classes = [ActiveStorage::Attached::Many, Array]
      permitable_classes.include?(@empty_obj.send(attr).class)
    end

    def permitted_columns
      p @empty_obj
      @columns = columns_for(@empty_obj)
      @columns.delete(:id)
      @columns.delete(:created_at)
      @columns.delete(:updated_at)

      @columns += @columns.select{|x| permit_array?(x)}.map do |attr|
        {attr=>[]}
      end
    end

    def verify_table_permissions!
      verify_permitted!(params[:table_name].to_sym)
    end
  end
end








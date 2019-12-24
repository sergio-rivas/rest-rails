require 'json'
module RestRails
  class DataController < ::ApplicationController
    include ApplicationHelper
    skip_before_action :verify_authenticity_token
    before_action :set_model, only: [:index, :show, :create, :update, :destroy, :fetch_column, :attach, :unattach]
    before_action :set_object, only: [:show, :update, :destroy, :fetch_column, :attach, :unattach]

    def index
      p_hash = index_params.to_h

      @objects = @model.all.in_groups_of(100) if p_hash.blank?
      @objects = @model.where(p_hash).in_groups_of(100) if p_hash.present?

      if params[:page].blank? || (params[:page].to_i < 1)
        if @objects.empty?
          @objects = []
        else
          @objects = @objects[0].reject{|x|x.nil?}.map{|x| standardize_json(x) }
        end
      else
        i = params[:page].to_i - 1
        objs = @objects[i]
        if objs.nil?
          @objects = []
        else
          @objects = objs.reject{|x|x.nil?}.map{|x| standardize_json(x) }
        end
      end

      render json: {code: 200, objects: @objects, count: @objects.count, total: @model.count}
    end

    def show
      render json: {code: 200, object: standardize_json(@object)}
    end

    def create
      @object = @empty_obj(model_params)

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

      render json: {code: 200, msg: "success", value: @object.public_send(params[:column])}
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
      arr.delete(:created_at)
      arr.delete(:updated_at)

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
      permitable_classes = [ActiveStorage::Attached::Many, Array]
      permitable_classes.include?(@empty_obj.send(attr).class)
    end

    def permitted_columns
      @columns = @model.attribute_names.map(&:to_sym)
      @columns.delete(:id)
      @columns.delete(:created_at)
      @columns.delete(:updated_at)

      @columns.map! do |attr|
        new_val = permit_array?(attr) ? {attr=>[]} : attr
        new_val
      end
      permitted_attachments if RestRails.active_storage_attachments
    end

    def permitted_attachments
      file_set = attachments_for(@empty_obj)
      file_set += file_set.select{|x| permit_array?(x)}.map do |attr|
        {attr=>[]}
      end

      @columns = @columns + file_set
    end
  end
end








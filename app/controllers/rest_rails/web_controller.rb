require 'json'
module RestRails
  class ApiController < ::DataController
    include ApplicationHelper

    def index
      super
      @objects.map!{|x| standardize_json(x) }

      render json: {code: 200, objects: @objects, count: @objects.count, total: @model.count}
    end

    def show
      super
      render json: {code: 200, object: standardize_json(@object)}
    end

    def create
      super do |obj|
        if obj
          render json: {code: 200, msg: "success", object: standardize_json(obj)}
        else
          render json: {code: 300, msg: "FAILED!"}
        end
      end
    end

    def update
      super do |obj|
        if obj
          render json: {code: 200, msg: "success", object: standardize_json(obj)}
        else
          render json: {code: 300, msg: "FAILED!"}
        end
      end
    end

    def destroy
      super do |bool|
        if bool
          render json: {code: 200, msg: "success"}
        else
          render json: {code: 300, msg: "FAILED!"}
        end
      end
    end

    def fetch_column
      super
      render json: {code: 200, msg: "success", value: prepare_column(@col_value)}
    end

    def attach
      super
      render json: {code: 200, msg: "success"}
    end

    def unattach
      super
      render json: {code: 200, msg: "success"}
    end
  end
end

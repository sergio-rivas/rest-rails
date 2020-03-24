module RestRails
  module ApplicationHelper
    def standardize_json(ar_object)
      h = ar_object.serializable_hash
      h.merge!(serial_attachments(ar_object)) if attachments_for(ar_object).present?
      h
    end

    # ==========================================================================
    #           SERIALIZE ATTACHMENTS FOR JSON
    # ==========================================================================

    def serial_attachments(ar_object)
      h = {}
      attachment_types = attachments_for(ar_object)
      attachment_types.each do |att|
        attached = ar_object.public_send(att)
        next if attached.nil?
        h[att]   = prepare_attachment(attached)
      end
      return h
    end

    def attachment_hash(attached)
      {attachment_id: attached.id, url: blob_link(attached)}
    end

    def blob_link(x)
      if Rails.env == "production"
        host = RestRails.production_domain || ""
      else
        host = RestRails.development_domain || "http://localhost:3000"
      end
      Rails.application.routes.url_helpers.rails_blob_url(x, host: host)
    end

    def prepare_column(col_value)
      if [ActiveStorage::Attached::Many, ActiveStorage::Attached::One].include?(col_value.class)
        return prepare_attachment(col_value)
      else
        return col_value
      end
    end

    def prepare_attachment(attached)
      if attached.class == ActiveStorage::Attached::Many
        return attached.map{|x| attachment_hash(x) }
      elsif attached.class == ActiveStorage::Attached::One
        x = attached.attachment
        return attachment_hash(x) unless x.nil?
      end
    end

    def attachments_for(ar_object)
      meths = ar_object.class.methods.map(&:to_s)
      attach_meths = meths.select{|x| x.include?("with_attached")}
      attach_meths.map{|x| x[14..-1].to_sym}
    end

    def columns_for(ar_object)
      table = ar_object.class.table_name.to_sym
      cols  = ar_object.class.column_names.map(&:to_sym)
      cols += attachments_for(ar_object) if RestRails.active_storage_attachments
      cols += nested_attributes_for(ar_object) unless ar_object.class.nested_attributes_options.blank?

      return cols if RestRails.permit == :all || RestRails.permit[table] == :all

      cols.select{|x| RestRails.permit[table].include?(x) }
    end

    def nested_attributes_for(ar_object)
      tables = ar_object.class.nested_attributes_options.keys

      tables.map do |x|
        cols = x.to_s.classify.constantize.column_names.map(&:to_sym)
        key = "#{x}_attributes".to_sym
        cols.delete(:id)

        {key => cols}
      end
    end



    # ==========================================================================
    #                 OTHER HELPERS
    # ==========================================================================

    def model_for(table_name)
      ignored = ["active_storage_blobs", "active_storage_attachments",
        "schema_migrations", "ar_internal_metadata"]
      tables = ActiveRecord::Base.connection.tables.reject{ |x| ignored.include?(x) }

      raise  RestRails::Error.new "Table '#{table_name}' does not exist in your database!" unless tables.include?(table_name)

      # Take the tablename, and make the Model of the relative table_name
      table_name.classify.constantize # "users" => User
    end

    def verify_permitted!(table)
      if [:none, nil].include?(RestRails.permit[table])
        raise RestRails::Error.new "NOT PERMITTED. Must add table to whitelisted params."
      elsif !RestRails.permit.is_a?(Hash) && (RestRails.permit != :all)
        raise RestRails::Error.new "RestRails initializer permit is not valid!"
      end
    end
  end
end

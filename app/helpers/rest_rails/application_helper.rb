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
      [Hash, :all].each do |y|
        x = RestRails.permit
        raise RestRails::Error.new "RestRails initializer permit is not valid!" unless x.is_a?(y) || (x == y)
      end

      cols = ar_object.class.column_names.map(&:to_sym)
      cols += attachments_for(ar_object) if RestRails.active_storage_attachments

      return cols if RestRails.permit == :all || RestRails.permit[table] == :all

      table = ar_object.class.table_name.to_sym
      raise RestRails::Error.new "ACTION NOT PERMITTED" if [:none, nil].include?(RestRails.permit[table])

      cols.select{|x| RestRails.permit[table].include?(x) }
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
  end
end

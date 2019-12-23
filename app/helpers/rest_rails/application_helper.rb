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
        attached = self.public_send(att)
        att_h    = {attachment_id: att.id, url: link_for_attached(attached)}
        h[att]   = att_h
      end
      return h
    end

    def blob_link(x)
      host = RestRails.domain
      Rails.application.routes.url_helpers.rails_blob_url(x, host: host)
    end

    def link_for_attached(attached)
      if attached.class == ActiveStorage::Attached::Many
        return attached.map{|x| blob_link(x) }
      elsif attached.class == ActiveStorage::Attached::One
        x = attached.attachment
        return blob_link(x) unless x.nil?
      end
    end

    def attachments_for(ar_object)
      meths = ar_object.class.methods.map(&:to_s)
      attach_meths = meths.select{|x| x.include?("with_attached")}
      attach_meths.map{|x| x[14..-1].to_sym}
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

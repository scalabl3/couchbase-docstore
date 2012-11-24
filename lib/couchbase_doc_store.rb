require 'couchbase'
require 'map'
require 'couchbase_settings'
require "couchbase_doc_store/version"

module CouchbaseDocStore

  #Rails.logger.debug(CouchbaseSetting.pm)
  
  setting_hash = {}      
  if (CouchbaseSetting.respond_to?("servers") && CouchbaseSetting.servers && !CouchbaseSetting.servers.empty?)
    setting_hash[:node_list] = CouchbaseSetting.servers 
  elsif CouchbaseSetting.respond_to?("server")
    
    setting_hash[:hostname] = CouchbaseSetting.server 
  else
    raise ArgumentError, "You didn't set a Couchbase Server in your /config/couchbase.yml file!"
  end
  setting_hash[:pool] = "default"
  setting_hash[:bucket] = CouchbaseSetting.bucket
  setting_hash[:port] = 8091
  
  if (CouchbaseSetting.respond_to?("password") && CouchbaseSetting.password && !CouchbaseSetting.password.blank?)
    setting_hash[:username] = CouchbaseSetting.bucket
    setting_hash[:password] = CouchbaseSetting.password
  end
  
  CB = Couchbase.connect(setting_hash)
  
  #### INSTANCE METHODS

  # Check if a key/document exists 
  def document_exists?(key)
    return nil unless key
    CouchbaseDocStore.document_exists?(key)
  end

  # Initialize a document, if it doesn't exist, create it, if it exists, ignore the call
  def initialize_document(key, value, args={})
    return nil unless key
    CouchbaseDocStore.initialize_document(key, value, args)
  end

  # Create a new document (Couchbase#add)
  def create_document(key, value, args={})
    return nil unless key
    CouchbaseDocStore.create_document(key, value, args) # => if !quiet, Generates Couchbase::Error::KeyExists if key already exists
  end

  # Replace a new document (Couchbase#replace), throws Couchbase::Error:: if it doesn't exist
  def replace_document(key, value, args = {})
    return nil unless key
    CouchbaseDocStore.replace_document(key, value, args)
  end

  # 
  def get_document(key, args = {})
    return nil unless key
    CouchbaseDocStore.get_document(key, args)
  end

  def get_documents(keys = [], args = {})
    return nil unless keys || keys.empty?
    CouchbaseDocStore.get_documents(keys, args)
  end

  def delete_document(key, args={})
    return nil unless key
    CouchbaseDocStore.delete_document(key, args)
  end

  # @param args :amount => Fixnum||Integer, increases by that
  def increase_atomic_count(key, args={})
    return nil unless key
    CouchbaseDocStore.increase_atomic_count(key, args)
  end

  def decrease_atomic_count(key, args={})
    return nil unless key
    CouchbaseDocStore.decrease_atomic_count(key, args)
  end

  # preferred way is to use create/replace to make sure there are no collisions
  def force_set_document(key, value, args={})
    return nil unless key
    CouchbaseDocStore.force_set_document(key, value, args)
  end



  # end Instance Methods
  #####################################################################
  #### CLASS METHODS

  class << self

    def delete_all_documents!
      CB.flush
    end

    def document_exists?(key)
      return nil unless key

      # Save quiet setting
      tmp = CB.quiet

      # Set quiet to be sure
      CB.quiet = true

      doc = CB.get(key)

      # Restore quiet setting
      CB.quiet = tmp

      !doc.nil?
    end

    def initialize_document(key, value, args={})
      return nil unless key
      CB.quiet = true
      doc = CouchbaseDocStore.get_document( key )
      (value.is_a?(Fixnum) || value.is_a?(Integer) ? CB.set( key, value ) : CB.add( key, value )) unless doc
    end

    def create_document(key, value, args={})
      return nil unless key
      CB.quiet = args[:quiet] || true
      CB.add(key, value, args) # => if !quiet, Generates Couchbase::Error::KeyExists if key already exists
    end

    def replace_document(key, value, args = {})
      return nil unless key
      CB.quiet = args[:quiet] || true
      CB.replace(key, value) # => if !quiet, Generates Couchbase::Error::NotFound if key doesn't exist
    end

    def get_document(key, args = {})
      return nil unless key
      CB.quiet = args[:quiet] || true
      doc = CB.get(key, args)
      doc.is_a?(Hash) ? Map.new(doc) : doc
    end

    def get_documents(keys = [], args = {})
      return nil unless keys || keys.empty?
      values = CB.get(keys, args)

      if values.is_a? Hash
        tmp = []
        tmp[0] = values
        values = tmp
      end
      # convert hashes to Map (subclass of Hash with *better* indifferent access)
      values.each_with_index do |v, i|
        values[i] = Map.new(v) if v.is_a? Hash
      end

      values
    end

    def delete_document(key, args={})
      return nil unless key
      CB.quiet = args[:quiet] || true
      CB.delete(key)
    end

    def increase_atomic_count(key, args={} )
      return nil unless key
      CB.quiet = args[:quiet] || true
      CB.incr(key, args[:amount] || 1)
    end

    def decrease_atomic_count(key, args={})
      return nil unless key
      CB.quiet = args[:quiet] || true
      CB.decr(key, args[:amount] || 1)
    end

    # preferred way is to use create/replace instead of this to make sure there are no collisions
    def force_set_document(key, value, args={})
      return nil unless key
      CB.quiet = args[:quiet] || true
      CB.set(key, value, args)
    end

  end# end ClassMethods

  #####################################################################

end
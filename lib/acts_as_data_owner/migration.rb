module ActiveRecord

  class Migration
    def acts_as_data_owner_for(table_name, *args)
      options = args.extract_options!
      fields  = [:creator, :owner, :updater]
      fields += [options[:include]].flatten if options[:include]
      fields -= [options[:exclude]].flatten if options[:exclude]
      prefix  = options[:prefix]            if options[:prefix]
      #Add fields to table
      change_table table_name do |t|
        fields.each do |f|
          t.references(f)
        end
      end

      #Add indexes
      fields.each do |f|
        add_index table_name, "#{f}_id",:name=>(prefix ? "#{prefix}_#{f}" : "index_#{table_name}_on_#{f}" )
      end
    end

    alias_method :data_owner, :acts_as_data_owner_for

  end
end
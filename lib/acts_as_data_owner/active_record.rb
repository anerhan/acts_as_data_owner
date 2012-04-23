module ActsAsDataOwner

  def acts_as_data_owner(*args)

    options = args.extract_options!
    fields = [:creator, :owner, :updater]
    fields += [options[:include]].flatten if options[:include]
    fields -= [options[:exclude]].flatten if options[:exclude]

    attr_protected fields.map { |f| "#{f}_id" }

    (fields-[:company]).each do |f|
      belongs_to f, :class_name => "Person", :foreign_key => "#{f}_id"
    end

    if fields.include?(:company)
      belongs_to :company
      before_create :set_company
    end
    before_create :set_creator_and_owner
    before_update :set_updater

    scope :current, lambda {
      #Filter by User Ids Who has access to Products
      if !Person.current.is_admin?
        conditions = {}
        conditions["#{self.table_name}.creator_id"] = ([Person.current.id] + Person.manage_people_ids).compact if fields.include?(:creator)
        conditions["#{self.table_name}.company_id"] = ([(Person.current.current_company ? Person.current.current_company.id : nil)] + Person.manage_company_ids).compact if fields.include?(:company)
        where(conditions)
      end
    }


    #has_paper_trail(:meta => {:person_id => Proc.new { |p| (p.updater_id || p.creator_id) }})

    include InstanceMethods
  end

  module InstanceMethods
    private

    def set_company
      self.company = Person.current.company
    end

    def set_creator_and_owner
      self.creator = Person.current
      self.owner = Person.current
    end

    def set_updater
      self.updater = Person.current
    end

  end
end


ActiveRecord::Base.extend ActsAsDataOwner


module ActiveRecord
  class Migration

    def acts_as_data_owner_for(table_name, *args)
      options = args.extract_options!
      fields = [:company, :creator, :owner, :updater]
      fields -= [options[:exclude]].flatten if options[:exclude]

      #Add fields to table
      change_table table_name do |t|
        fields.each do |f|
          t.references(f)
        end
      end

      #Add indexes
      fields.each do |f|
        add_index table_name, "#{f}_id"
      end
    end

  end
end
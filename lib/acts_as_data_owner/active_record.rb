# -*- encoding: utf-8 -*-


module ActsAsDataOwner


  def acts_as_data_owner(*args)

    options = args.extract_options!
    fields = [:creator, :owner, :updater]
    fields += [options[:include]].flatten if options[:include]
    fields -= [options[:exclude]].flatten if options[:exclude]

    attr_protected fields.map { |f| "#{f}_id" }

    (fields-[:company]).each do |f|
      belongs_to f, :class_name => "Person", :foreign_key => "#{f}_id"
      before_create :"set_#{f}"
    end

    if fields.include?(:company)
      belongs_to :company
      before_create :set_company
    end


    scope :current, lambda {
      conditions = {}
      #Filter by User Ids Who has access to Products
      if !Person.current.is_admin?

        conditions["#{self.table_name}.owner_id"] = ([Person.current.id] + Person.manage_people_ids).compact if fields.include?(:owner)

        if fields.include?(:company)
          company_ids = ([(Person.current.current_company ? Person.current.current_company.id : nil)] + Person.manage_company_ids).compact
          conditions["#{self.table_name}.company_id"] = company_ids if company_ids.any?
        end
      end
      where(conditions)
    }


    #has_paper_trail(:meta => {:person_id => Proc.new { |p| (p.updater_id || p.creator_id) }})

    include InstanceMethods
  end

  alias_method :data_owner, :acts_as_data_owner

  module InstanceMethods
    private

    def set_company
      self.company = Person.current.company
    end

    def set_creator
      self.creator = Person.current
    end

    def set_owner
      self.owner = Person.current
    end

    def set_updater
      self.updater = Person.current
    end

  end
end






class Types::BaseObject < GraphQL::Schema::Object
  def self.pundit_authorized?(admin, object, action)
    begin
      Pundit.authorize(admin, object, action)
      true
    rescue Pundit::NotAuthorizedError
      false
    end
  end
end

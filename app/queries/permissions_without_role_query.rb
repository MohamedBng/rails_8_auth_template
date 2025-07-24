class PermissionsWithoutRoleQuery
  DEFAULT_PER_PAGE = 10

  attr_reader :role, :params, :page, :per_page, :search

  def self.call(role:, params: {}, page: 1, per_page: DEFAULT_PER_PAGE)
    new(role: role, params: params, page: page, per_page: per_page).call
  end

  def initialize(role:, params:, page:, per_page:)
    @role     = role
    @params   = params.presence || {}
    @page     = page.to_i
    @per_page = per_page
  end

  def call
    {
      permissions:  search.result(distinct: true)
                  .page(page)
                  .per(per_page),
      search: search
    }
  end

  private

  def base_relation
    Permission
      .without_role(role)
      .includes(:roles)
      .order(name: :asc)
  end

  def search
    @search ||= base_relation.ransack(params)
  end
end

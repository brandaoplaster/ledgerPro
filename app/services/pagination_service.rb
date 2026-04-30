class PaginationService
  def initialize(relation, page: 1, per_page: 10)
    @relation = relation.is_a?(Class) ? relation.all : relation
    @page = [ page.to_i, 1 ].max
    @per_page = [ [ per_page.to_i, 1 ].max, 100 ].min
  end

  def call
    total_count = @relation.count
    total_pages = (total_count.to_f / @per_page).ceil
    offset = (@page - 1) * @per_page

    {
      records: @relation.limit(@per_page).offset(offset).to_a,
      current_page: @page,
      total_pages: total_pages,
      total_count: total_count
    }
  end
end

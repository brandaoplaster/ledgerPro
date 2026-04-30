module ApplicationHelper
  def icon(name, **opts)
    render "shared/icons/#{name}", **opts
  end
end

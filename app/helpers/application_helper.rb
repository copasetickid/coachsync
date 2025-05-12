module ApplicationHelper
  def nav_link_classes(path)
    classes = "inline-flex items-center px-1 pt-1 text-sm font-medium border-b-2 h-full"

    if current_page?(path)
      classes += " border-blue-500 text-gray-900"
    else
      classes += " border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
    end

    classes
  end
end
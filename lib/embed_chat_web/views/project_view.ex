defmodule EmbedChatWeb.ProjectView do
  use EmbedChatWeb, :view

  def project_name(project) do
    if name = project.name do
      name
    else
      "unnamed"
    end
  end
end

defmodule EmbedChat.ProjectView do
  use EmbedChat.Web, :view

  def project_name(project) do
    if name = project.name do
      name
    else
      "unnamed project"
    end
  end
end

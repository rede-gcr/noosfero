class TestController < ApplicationController

  uses_flexible_template :owner => 'owner'

  def index
    render :text => 'index'
  end

  post_only 'post_only'
  def post_only
    render :text => '<span>post_only</span>'
  end

  def help_with_string
    render :inline => '<%= help "my_help_message" %>'
  end

  def help_with_block
    render :inline => '
      <% help do %>
        my_help_message
      <% end %>
    '
  end

  def help_textile_with_string
    render :inline => '<%= help_textile "*my_bold_help_message*" %>'
  end

  def help_textile_with_block
    render :inline => '
      <% help_textile do %>
        *my_bold_help_message*
      <% end %>
    '
  end

end

class BackgroundRefresh
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper
  include SuckerPunch::Job

  def perform(user_id)
    current_user = User.find(user_id)
    if current_user.posts.any?
      old_top_post_date = current_user.posts.all.sort_by(&:created_at).reverse.first.created_at
    end
    ActiveRecord::Base.connection_pool.with_connection do
      Post.refresh_cache!(current_user)
      new_top_post_date = current_user.posts.all.sort_by(&:created_at).reverse.first.created_at

      # unless new_top_post_date == old_top_post_date
        posts = current_user.posts.all.sort_by(&:created_at).reverse
        # Rails.logger.debug "#{posts_html(posts)}"
        num_of_new_messages = current_user.posts.where("created_at > ?", old_top_post_date).count
        num_of_new_messages == 1 ? subject_verb_agreement = "is" : subject_verb_agreement = "are"
        num_of_posts_text = "There #{subject_verb_agreement} #{pluralize(num_of_new_messages, 'new post')}"

        PrivatePub.publish_to("/messages/#{user_id}", "$('#new_posts_notification').show();document.getElementById('new_posts_count').innerHTML = '#{num_of_posts_text}';$('.posts').html(#{posts_html(posts).html_safe.inspect});")
      # end
    end
  end

  def posts_html(posts)
    html = ""
    posts.each do |post|
      html +=
      "<div class=\'panel panel-default posts\'><div class=\'panel-heading\'> <a href=\'#{post[:user_url]}\' target=\'_blank\'>   <img href=\'#{post[:user_image_url]}\' style=\'float: left; padding-right: 10px; max-width:50px; max-height:50px;\'>   <strong>#{post[:user_screen_name]}</strong><br>"
      if post[:user_name].nil?
        html +=
        "<i class=\'fa fa-<%= post[:provider] %> pull-right\'></i><br>"
      else
        html += "@" + post[:user_name] + "<i class=\'fa fa-#{post[:provider]} pull-right\'></i>"
      end
      html += "</a></div><div class=\'panel-body\'>#{post[:text]}<br><br>"
      unless post[:picture_url].nil?
        html += "<img href=\'#{post[:picture_url]}\'><br><br>"
      end
      unless post[:link].nil?
        html +=
        "<div>  <a href=\'#{post[:link]}\'>#{post[:name]}</a><br>  #{post[:link_caption]}</div><br>"
      end
      unless post[:story].nil?
        html += "#{post[:story]}<br><br>"
      end
      if post[:created_at] > Time.now.beginning_of_day
        html += "<a href=\'#{post[:url]}\'>#{time_ago_in_words(post[:created_at])} ago</a>"
      else
        html += "<a href=\'#{post[:url]}\'>#{post[:created_at].strftime("%b %d")} ago</a>"
      end
      html += "</div></div>"
    end
    return html
  end
end

# Delete all posts from target div
# For each post in list of posts
# add a post div back to target div
# Show old posts

## auto-show all (new) posts after BackgroundRefresh

## say how many new posts, hide them until twitter-like notification clicked
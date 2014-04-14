class BackgroundRefresh
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper
  include SuckerPunch::Job

  def perform(user_id)
    current_user = User.find(user_id)
    if current_user.posts.any?
      old_top_post_date = current_user.posts.all.sort_by(&:created_at).reverse.first.created_at
    end
    Post.refresh_cache!(current_user)
    if current_user.posts.any?

      new_top_post_date = current_user.posts.all.sort_by(&:created_at).reverse.first.created_at

      unless new_top_post_date == old_top_post_date
        new_posts = current_user.posts.where("created_at > ?", old_top_post_date).sort_by(&:created_at).reverse
        num_of_new_messages = current_user.posts.where("created_at > ?", old_top_post_date).count

        PrivatePub.publish_to("/messages/#{user_id}",
          "$('#new_posts_notification').slideDown(500);
          var current_new_count = document.getElementById('new_posts_count').innerHTML;
          var total_new_count = parseInt(current_new_count) + #{num_of_new_messages};
          if(total_new_count == 1) {subject_verb_agreement_prefix = ' is ';} else {subject_verb_agreement_prefix = ' are ';};
          if(total_new_count == 1) {correct_pluralization_postfix = ' post';} else {correct_pluralization_postfix = ' posts';};
          var new_posts_message_text = 'There ' + subject_verb_agreement_prefix + '<span id\=\"new_posts_count\">' + total_new_count + '</span>' + ' new' + correct_pluralization_postfix;
          $('#new_posts_message').html(new_posts_message_text);
          $(#{posts_html(new_posts).html_safe.inspect}).insertBefore('.posts .panel:nth-child(1)');"
          )
      end
    end
  end

  def posts_html(posts)
    html = ""
    posts.each do |post|
      html +=
      "<div class=\'panel panel-default new_post\' style=\'display: none\'><div class=\'panel-heading\'> <a href=\'#{post[:user_url]}\' target=\'_blank\'>   <img src=\'#{post[:user_image_url]}\' style=\'float: left; padding-right: 10px; max-width:50px; max-height:50px;\'>   <strong>#{post[:user_screen_name]}</strong><br>"
      if post[:user_name].nil?
        html += "<i class=\'fa fa-#{post[:provider]} pull-right\'></i><br>"
      else
        html += "@" + post[:user_name] + "<i class=\'fa fa-#{post[:provider]} pull-right\'></i>"
      end
      html += "</a></div><div class=\'panel-body\'>#{post[:text]}<br><br>"
      unless post[:picture_url].nil?
        html += "<img src=\'#{post[:picture_url]}\'><br><br>"
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

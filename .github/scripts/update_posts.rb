require 'httparty'
require 'nokogiri'
require 'octokit'

# script from: https://www.bengreenberg.dev/posts/2023-04-09-github-profile-dynamic-content/

# Scrape blog posts from the website
url = "https://www.bengreenberg.dev/blog/"
response = HTTParty.get(url)
parsed_page = Nokogiri::HTML(response.body)
posts = parsed_page.css('.flex.flex-col.rounded-lg.shadow-lg.overflow-hidden')

# Generate the updated blog posts list (top 5)
posts_list = ["\n### Recent Blog Posts\n\n"]
posts.first(5).each do |post|
  title = post.css('p.text-xl.font-semibold.text-gray-900').text.strip
  link = "https://www.bengreenberg.dev#{post.at_css('a')[:href]}"
  posts_list << "* [#{title}](#{link})"
end

# puts "Hello World"

# Update the README.md file
client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
repo = ENV['GITHUB_REPOSITORY']
puts "repo below"
puts ENV['GITHUB_REPOSITORY']
puts "end repo"
readme = client.readme(repo)

# below errors
#readme_content = Base64.decode64(readme[:content]).force_encoding('UTF-8')

# puts "readme begin"
# puts readme_content
# puts "end readme"

# puts "posts_list begin----------------"
# puts posts_list
# puts "posts_list end------------------"

# Replace the existing blog posts section
posts_regex = /### Recent blog posts\n\n[\s\S]*?(?=<\/td>)/m
#posts_regex = /### Recent blog posts[\s\S]*?(?=<\/td>)/m
# puts "regex begin----------------"
# puts posts_regex
# puts "regex end------------------"

# commenting out because of readme_content error above
#updated_content = readme_content.sub(posts_regex, "#{posts_list.join("\n")}\n")

# puts "updated_content begin----------------"
# puts updated_content
# puts "updated_content end------------------"
# updated_content = "test"
time2 = Time.now
puts "Current Time : " + time2.inspect
updated_content = "Recent blog posts " + time2.inspect

client.update_contents(repo, 'README.md', 'Update recent blog posts', readme[:sha], updated_content)

require 'feedjira'
require 'httparty'
require 'jekyll'

module ExternalNews
  class ExternalNewsGenerator < Jekyll::Generator
    safe true
    priority :high

    def generate(site)
      if site.config['external_news_sources'] != nil
        site.config['external_news_sources'].each do |src|
          p "Fetching external news from #{src['name']}:"
          xml = HTTParty.get(src['rss_url']).body
          feed = Feedjira.parse(xml)
          feed.entries.each do |e|
            p "...fetching #{e.url}"
            slug = e.title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
            path = site.in_source_dir("_external_news/#{slug}.md")
            doc = Jekyll::Document.new(
              path, { :site => site, :collection => site.collections['external_news'] }
            )
            doc.data['external_source'] = src['name'];
            doc.data['external_source_url'] = src['url'];
            doc.data['feed_content'] = e.content;
            doc.data['title'] = "#{e.title}";
            doc.data['description'] = e.summary;
            doc.data['date'] = e.published;
            doc.data['redirect'] = e.url;
            site.collections['external_news'].docs << doc
          end
        end
      end
    end
  end

end

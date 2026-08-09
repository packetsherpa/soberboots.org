#!/usr/bin/env ruby
# frozen_string_literal: true

# Converts the remaining Jekyll-only URL helper expressions after _posts has
# been moved to content/posts. Hugo accepts the existing YAML front matter.
Dir.glob("content/posts/**/*.{md,markdown,html}").each do |path|
  source = File.read(path)
  basename = File.basename(path, File.extname(path))
  date, slug = basename.match(/\A(\d{4}-\d{2}-\d{2})-(.+)\z/)&.captures
  slug = slug.gsub(/-+/, "-") if slug
  legacy_path = "/soberboots/#{date.tr('-', '/')}/#{slug}/" if date && slug
  converted = source
    .gsub(%r!\{\{\s*['"](/soberboots/[^'"]+)['"]\s*\|\s*relative_url\s*\}\}!, '\\1')
    .gsub(%r!\{\{\s*['"](/[^'"]+)['"]\s*\|\s*relative_url\s*\}\}!, '\\1')
  converted = converted.gsub(/^image: (.+)$/) { "cover:\n  image: #{$1}\n  alt: #{File.basename($1).inspect}" }
  if legacy_path && !converted.include?("aliases:")
    converted = converted.sub(/\A---\n/, "---\nslug: #{slug.inspect}\naliases: [#{legacy_path.inspect}]\n")
  end
  File.write(path, converted) if converted != source
end

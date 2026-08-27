#!/usr/bin/env ruby
# Render GitHub issue forms into a markdown skeleton an agent can paste into
# `gh issue create --body-file`.
#
# Issue forms are a web-UI feature: an issue opened through the API gets none of
# their structure, and the YAML cannot be used as a body. So the fields have to be
# reproduced by hand — which is only possible if they are written down somewhere
# the agent can read. That is what this generates.
#
# Usage: render-issue-forms.rb <form.yml> [<form.yml> ...]

require "yaml"

# Fields the form asks for, in order. markdown blocks are guidance for the web
# form and carry no field, so they are dropped.
def fields(doc)
  (doc["body"] || []).reject { |b| b["type"] == "markdown" }
end

puts <<~HEAD
  # Issue templates, as markdown

  The issue templates are **GitHub issue forms**. They apply only in the web
  UI — an issue opened with `gh issue create` or through the API gets none of their
  structure, and the YAML cannot be passed as a body. Reproduce the fields below by
  hand, and set the type explicitly with `--type`.

  ```sh
  gh issue create --type Bug --title "..." --body-file body.md
  ```
HEAD

ARGV.each do |path|
  doc = YAML.load_file(path)
  puts
  puts "## #{doc["name"]}"
  puts
  puts "`--type #{doc["type"]}` · #{doc["description"]}" if doc["type"]
  puts
  puts "Fields, in order:"
  puts

  fields(doc).each do |f|
    label = f.dig("attributes", "label")
    required = f.dig("validations", "required") ? "required" : "optional"
    kind = f["type"] == "dropdown" ? "choose one" : f["type"]
    puts "- **#{label}** — #{required}, #{kind}"
    desc = f.dig("attributes", "description")
    if desc && !desc.strip.empty?
      # Collapse to one line; the full guidance lives in the form itself.
      puts "  #{desc.strip.gsub(/\s*\n\s*/, " ")}"
    end
    opts = f.dig("attributes", "options")
    puts "  Options: #{opts.join(", ")}" if opts
  end

  puts
  puts "Body skeleton:"
  puts
  puts "````markdown"
  fields(doc).each do |f|
    label = f.dig("attributes", "label")
    render = f.dig("attributes", "render")
    value = f.dig("attributes", "value")
    puts "## #{label}"
    puts
    if render
      puts "```#{render}"
      puts
      puts "```"
    elsif value && !value.strip.empty?
      # A prefilled field: the web form starts you with this, so the skeleton should too.
      puts value.rstrip
    else
      puts "<!-- #{f.dig("validations", "required") ? "required" : "optional"} -->"
    end
    puts
  end
  puts "````"
end

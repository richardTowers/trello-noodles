require "trello"
require "erb"
require "open3"

Trello.configure do |config|
  config.developer_public_key = ENV.fetch('TRELLO_KEY')
  config.member_token = ENV.fetch('TRELLO_TOKEN')
end

TRELLO_BOARD_ID = 'QiyLAAxa'
CARD_PATTERN = /https:\/\/trello[.]com\/c\/[A-Za-z0-9]+/

GraphNode = Struct.new(:id, :label, :href, :desc, :tags)
GraphEdge = Struct.new(:from, :to)

def get_card_url_prefix(url)
  url.match(CARD_PATTERN)[0]
end

def main
  board = Trello::Board.find(TRELLO_BOARD_ID)
  cards = board.cards

  graph_nodes = cards.map do |card|
    GraphNode.new(
      get_card_url_prefix(card.url),
      card.name.gsub('"', '\"'),
      card.url,
      card.desc,
      card.labels.map{ |l| l.name },
    )
  end

  graph_edges = graph_nodes.flat_map do |node|
    node.desc.scan(CARD_PATTERN).map do |match|
      GraphEdge.new(node.id, match)
    end
  end

  nodes_with_edges = graph_nodes.filter do |node|
    graph_edges.any? do |edge|
      edge.from == node.id || edge.to == node.id
    end
  end

  template = <<~'ERB'
  digraph g {

    <% nodes_with_edges.each do |node| %>
    "<%= node.id %>" [
      label = <
        <table border="0" cellborder="1" cellspacing="0" cellpadding="4">
          <tr><td href="<%= node.href %>"><font color="#1d70b8"><u><%= node.label %></u></font></td></tr>
          <% node.tags.each do |tag| %>
          <tr><td><%= tag %></td></tr>
          <% end %>
        </table>
      >
      shape = none
      fontname = "Arial"
    ]
    <% end %>

    <% graph_edges.each do |edge| %>
    "<%= edge.from %>" -> "<%= edge.to %>"
    <% end %>

  }
  ERB

  graphviz_input = ERB.new(template).result(binding)
  graphviz_output, status = Open3.capture2("dot", "-Tsvg", stdin_data: graphviz_input)
  puts graphviz_output
end

main

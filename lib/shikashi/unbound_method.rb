class UnboundMethod
  def body
    if source_location
      Shikashi::Method::Node.new(source_location[0], source_location[1])
    else
      Shikashi::Method::Node.new('', 0)
    end
  end
end
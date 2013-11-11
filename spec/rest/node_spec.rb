require "spec_helper"

module Neo4j
  describe Node::Rest, api: :rest do
    describe "instance method" do
      describe "new" do
        context "using current session" do
          it "creates a node" do
            node = Node.new name: "Ujjwal", email: "ujjwalthaakar@gmail.com"
            expect(node.name).to eq("Ujjwal")
            expect(node.email).to eq("ujjwalthaakar@gmail.com")
          end
        end
      end
    end
  end
end

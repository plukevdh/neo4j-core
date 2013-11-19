module Neo4j
  shared_examples "Relationship" do
    let(:api) { example.metadata[:api] }
    let (:another_session) do
      another_session = Session.new(api)
      another_session.start
      another_session
    end

    let(:start_node) { Node.new name: "Ujjwal Thaakar", age: 21 }
    let(:end_node) { Node.new name: "Andreas Ronge", nationaility: :sweedish }

    describe "instance method" do
      let(:rel) { Relationship.new start_node, :KNOWS, end_node, since: Date.parse("29/10/2013"), through: "Gmail" }

      describe "type" do
        it "returns the type of the relationship" do
          expect(rel.type).to eq("KNOWS")
        end
      end

      describe "[properties]" do
        context "when the properties exist" do
          it "returns the an array of values for those properties" do
            expect(rel[:since, :through]).to eq(["2013-10-29", "Gmail"])
          end
        end

        context "when the properties doesn't exist" do
          it "returns a empty array" do
            expect(rel[:favourite_language, :favourite_database]).to be_empty
          end
        end
      end

      describe "[properties] = values" do
        context "when the value is a ruby object" do
          it "sets property to value" do
            rel[:since, :through] = "4/11/2013", "Google+"
            expect(rel[:since, :through]).to eq(["4/11/2013", "Google+"])
            rel[:through] = "Twitter"
            expect(rel[:through]).to include("Twitter")
          end
        end

        context "value is nil" do
          context "when the property exists" do
            it "removes the property" do
              rel[:since, :through] = nil, nil
              expect(rel[:since, :through]).to be_empty
            end
          end

          context "when the property doesn't exist" do
            it "does nothing" do
              rel[:favourite_language] = nil
              expect(rel[:favourite_language]).to be_nil
            end
          end
        end
      end

      describe "delete" do
        let(:rel) { Relationship.new start_node, :RANDOM, end_node, since: Date.parse("29/10/2013"), through: "Gmail" }
        it "deletes the node" do
          rel.delete
          expect { rel[:since] }.to raise_error(StandardError)
        end
      end
    end

    describe "class method" do
      let(:rel) { Relationship.new start_node, :FRIEND_OF, end_node, since: 2013, random_property: "who cares?" }
      describe "new(type, start, end, attributes = {})" do
        it "returns nil if both nodes aren't from the same session" do
          another_session = Session.new :rest
          node_from_another_session = Node.new({name: "Ujjwal", email: "ujjwalthaakar@gmail.com"}, :from_another_session, another_session)
          expect {Relationship.new start_node, :NAME, node_from_another_session}.to raise_error
        end

        it "is an instance of the correct subclass" do
          expect(rel).to be_an_instance_of(described_class)
        end
      
        it "has the correct start node" do
          expect(rel.start).to eq(start_node)
        end

        it "has the correct end node" do
          expect(rel.end).to eq(end_node)
        end

        it "has the correct properties" do
          expect(rel[:since, :random_property]).to eq([2013, "who cares?"])
        end

        it "does not have the wrong properties" do
          expect(rel[:invalid_property]).to be_nil
        end
      end

      describe "load(id)" do
        let(:same_rel) { Relationship.load(rel.id, Session.current) }
        it "load the relationship with the given id" do
          expect(rel).to eq(same_rel)
        end

        it "has the same start node" do
          expect(rel.start).to eq(same_rel.start)
        end

        it "has the same end node" do
          expect(rel.end).to eq(same_rel.end)
        end

        it "has the same type" do
          expect(rel.type).to eq(same_rel.type)
        end
      end
    end
  end
end
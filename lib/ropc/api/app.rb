class TagApp < Sinatra::Base

  # create OPC connection
  def conn(tags)
        ROPC::Client.new(tags: tags, server: settings.server, node: settings.node)
  end

  def save
        File.open(settings.db, "w") do |f|
                f.puts JSON.pretty_generate(@tags)
        end                        
  end

  # get storage
  before do
        if File.exists?(settings.db) 
                @tags = JSON.parse(File.read(settings.db))
        else 
                @tags = []
        end
  end
  
  # get all tags
  get '/tags' do
        content_type :json
        JSON.pretty_generate(conn(@tags).read)
  end

  # get tags with tagid
  get '/tags/:id' do
        if @tags.include?(params[:id])
                content_type :json
                JSON.pretty_generate(conn(params[:id]).read)
        else
                "Coult not read tag."
        end
  end

  # create tag with tagid
  post '/tags/:id' do
        if @tags.include?(params[:id])
                "tag already created."
        else 
                @tags << params[:id].to_s
                save
                "tag created."
        end
  end
  
  # delete tag with tagid
  delete '/tags/:id' do
        if @tags.include?(params[:id])
                @tags.delete(params[:id])
                save
                "tag deleted."
        else                 
                "tag not found."
        end
  end
  
  
  get '/' do
        "nothing to see here"
  end
  
end

function create_agregator(start_content, documentation_goal, output, classification_props)
    
    local agregator  ={}
    local instructions_md = dtw.load_file(script_dir_name.."../assets/instructions.md")
    agregator.content = start_content or ""
    local aready_digest = {}    
    agregator.digest = function(content,filename)
        local generated_content = ""
        local llm = newLLM()
        llm.add_system_prompt("old content:"..agregator.content.."\n---------------\n")
        llm.add_user_prompt("\ndocumentation goals:"..documentation_goal.."\n------------\n")
        if filename then 
            llm.add_user_prompt("filename:"..filename.."\n")
        end 
        llm.add_user_prompt("file-content:"..content.."\n---------\n")    
        llm.add_system_prompt(instructions_md)  
        
            llm.add_function(
          "set_content",
          "set the content of the agregator",
         {{
            name = "content",
            type = "string",
            description = "The content to be set",
            required=true
         }},
         function(args)
            generated_content= args.content
         end
        )
        llm.generate()


        if generated_content then 
      
            local insert = clasify_modification(classification_props, agregator.content, generated_content, documentation_goal)
            if insert then 
                agregator.content = generated_content
                return "inserted"
            end 
            if not insert then 
                return "denied by the classifier"
            end
        end
        
        return "not inserted"

    end 

    agregator.digest_file = function(file_path)
        for _, already_digested in ipairs(aready_digest) do
            if already_digested == file_path then
                print("file already digested: " .. file_path)
                return
            end
        end
        table.insert(aready_digest, file_path)
        
        local file_content = dtw.load_file(file_path)
        local result  = agregator.digest(file_content,file_path)
        print("file digested:" .. file_path.." result: " .. tostring(result))
        if result == "inserted" then 
            dtw.write_file(output, agregator.content)
        end 
    end


    agregator.digest_path_list = function(path_list)
        local files = {}




        for _, path in ipairs(path_list) do
            if dtw.isfile(path) then
                table.insert(files, path)
            elseif dtw.isdir(path) then
                local dir_files = dtw.list_files_recursively(path, true)
                for _, file in ipairs(dir_files) do
                    table.insert(files, file)
                end
            end
        end
        
        local randonizer = dtw.newRandonizer()
        -- Shuffle the files randomly
        for i=1,#files *10 do
            local first_index = randonizer.generate_num(#files) +1 
            local second_index = randonizer.generate_num(#files) +1 
            --print("swapping " .. first_index .. " with " .. second_index)
            local temp = files[first_index]
            files[first_index] = files[second_index]
            files[second_index] = temp
        end
        for _, current_file in ipairs(files) do
            print("\n\ndigesting file: " .. current_file)
            agregator.digest_file(current_file)
        end
        
    end
    return agregator
end
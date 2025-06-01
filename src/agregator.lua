

function create_agregator(start_content, documentation_goals, output)
    
    local agregator  ={}
    local instructions_md = dtw.load_file(current_dir.."../assets/instructions.md")
    agregator.content = start_content or ""
    agregator.digest = function(content)
        local agregated = false 
        local llm = newLLM()
         llm.add_system_prompt(instructions_md)  
        llm.add_user_prompt("\ndocumentation goals:"..documentation_goal.."\n------------\n")
         llm.add_function(
          "set_content",
          "set the formatted content",
         {{
            name = "content",
            type = "string",
            description = "The content to be set"
         }},
         function(args)
            agregated = true
            agregator.content = args.content
         end
        )
         llm.generate()
        return agregated
    end 

    agregator.digest_file = function(file_path)
        local file_content = dtw.load_file(file_path)
        local digested = agregator.digest(file_content)
        if digested then 
            print("file digested: " .. file_path)
            dtw.write_file(output, agregator.content)
        else
            print("file not digested: " .. file_path)
        end
    end

    agregator.digest_dir = function(dirname)
        local files = dtw.list_files_recursively(dirname)
        for _, file in ipairs(files) do
            agregator.digest_file(file)
        end
    end 
    agregator.digest_path = function(path)
        if dtw.isfile(path) then
            return agregator.digest_file(path)
        elseif dtw.isdir(path) then
            return agregator.digest_dir(path)
        else
            error("Invalid path: " .. path)
        end
    end 
    agregator.digest_path_list = function(path_list)
        for _, path in ipairs(path_list) do
            agregator.digest_path(path)
        end
    end
    return agregator
end


function create_agregator(agregation_model,verifiver_model,total_verification)
    
    local agregator  ={}
    local instructions_md = dtw.load_file(current_dir.."../assets/instructions.md")
    agregator.content = ""
    agregator.digest = function(content)
        local agregated = false 
        local llm = newLLM({model=agregation_model})
         llm.add_system_prompt(instructions_md)  

         llm.add_function(
          "set_content",
          "set the formmated content",
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
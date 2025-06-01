relative_load("agregator.lua")
relative_load("flags.lua")

function main()
    local paths_size = argv.get_flag_size(PATHS)
    local paths = {}
    for i=1,paths_size do 
        paths[i] = argv.get_flag_arg_by_index(PATHS, i)
    end 
    if #paths == 0 then 
        error("At least one path is required")
    end
    
    local entrie_content = ""
    local entrie_file = argv.get_flag_arg_by_index(ENTRIES, 1)
    if entrie_file then 
        entrie_content = dtw.load_file(entrie_file)
    end

    
    local output = argv.get_flag_arg_by_index(OUTPUT, 1)
    if not output then 
        error("--output file is required")
    end
    local goal = argv.get_flag_arg_by_index(GOAL,1)
    if not goal  then 
        error("--goal are required")
    end 
    local agregator = create_agregator(
        entrie_content,
        goal,
        output
    )   
    agregator.digest_path_list(paths)
    print("Aggregation completed.")



end 

main()
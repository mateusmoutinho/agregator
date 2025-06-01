relative_load("agregator.lua")

function main()
    local paths_size = argv.get_flag_size({ "path", "p" })
    local paths = {}
    for i=1,paths_size do 
        paths[i] = argv.get_flag_arg_by_index({ "path", "p" }, i)
    end 

    local entrie_content = ""
    local eentrie_file = argv.get_flag_arg_by_index({ "entrie", "e" }, 1)
    if entrie_file then 
        entrie_content = dtw.load_file(eentrie_file)
    end
    local output = argv.get_flag_arg_by_index({ "output", "o" }, 1)
    if not output then 
        error("Output file is required")
    end

    local agregator = create_agregator(
        entrie_content,
        output
    )   
    agregator.digest_path_list(paths)
    print("Aggregation completed.")



end 

main()
std                     = "lua53"
globals                 = {
    'Ann',
    'UnLua',
    'UE',
    'rapidjson',
    "pass"
}

include_files           = {
    'Content/Script/**/*.lua'
}

exclude_files           = {
    'Content/Script/ThirdParty/**/*.lua',
	'Content/Script/UnLua/**/*.lua',
}

ignore = {
  '212',
}

max_line_length         = 500
max_code_line_length    = 500
max_string_line_length  = 500
max_comment_line_length = 500

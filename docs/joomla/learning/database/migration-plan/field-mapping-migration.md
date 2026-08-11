# Joomla Core Field Mapping — Joomla 3.10.12 → Joomla 6.1.2

> 711/711 J3 fields are explicit; canonical V3/V6 field inventories remain the DDL/type source of truth. J6 target coverage is 76/76 tables and 832/832 fields.

**Codes:** M=D direct, T transform, L lookup, S structured, G generated, B rebuild, R reference-only, A archive, I ignore. X=lookup domain/parser/special rule: DT date/null, ASSET, TREE, PW password, 2FA, HID/HSN history, ML/MS menu, FI/FV fields, AI/AK associations, UCM, TAG, WF workflow, FT featured, FM Finder count, PT privacy. Row order is V3 ordinal. Target field is same-name in the target table from `table-mapping-migration.md` unless overridden below.

Verification follows M+X: D schema-safe equality; T semantic conversion; L target exists/no orphan; S parse→remap→reparse; G deterministic; B integrity; R semantic identity; A archive count; I accounted reason. Same-name alone never permits D. IDs use `value_mapping`; sentinels and polymorphic context are resolved before lookup. Unknown/review/pending/optional/ambiguous/unmapped are forbidden.

# Source rows — 711/711

## G0
### #__extensions
|Source|M|X|
|---|:-:|---|
|extension_id|R||
|package_id|R||
|name|R||
|type|R||
|element|R||
|folder|R||
|client_id|R||
|enabled|R||
|access|R||
|protected|R||
|manifest_cache|R||
|params|R||
|custom_data|R||
|system_data|A||
|checked_out|R||
|checked_out_time|R||
|ordering|R||
|state|R||
### #__schemas
|Source|M|X|
|---|:-:|---|
|extension_id|R||
|version_id|R||
### #__update_sites
|Source|M|X|
|---|:-:|---|
|update_site_id|R||
|name|R||
|type|R||
|location|R||
|enabled|R||
|last_check_timestamp|R||
|extra_query|R||
### #__update_sites_extensions
|Source|M|X|
|---|:-:|---|
|update_site_id|R||
|extension_id|R||
### #__updates
|Source|M|X|
|---|:-:|---|
|update_id|R||
|update_site_id|R||
|extension_id|R||
|name|R||
|description|R||
|element|R||
|type|R||
|folder|R||
|client_id|R||
|version|R||
|data|R||
|detailsurl|R||
|infourl|R||
|extra_query|R||
## G1
### #__languages
|Source|M|X|
|---|:-:|---|
|lang_id|L|LANGUAGE|
|asset_id|L|ASSET|
|lang_code|D||
|title|D||
|title_native|D||
|sef|D||
|image|S|MEDIA_PATH|
|description|D||
|metakey|D||
|metadesc|D||
|sitename|D||
|published|D||
|access|L|VIEWLEVEL|
|ordering|D||
### #__usergroups
|Source|M|X|
|---|:-:|---|
|id|L|USERGROUP|
|parent_id|L|USERGROUP|
|lft|G|TREE|
|rgt|G|TREE|
|title|D||
### #__users
|Source|M|X|
|---|:-:|---|
|id|L|USER|
|name|D||
|username|D||
|email|D||
|password|T|PW|
|block|D||
|sendEmail|D||
|registerDate|T|DT|
|lastvisitDate|T|DT|
|activation|D||
|params|S|JOOMLA_REGISTRY/JSON|
|lastResetTime|T|DT|
|resetCount|D||
|otpKey|A|2FA|
|otep|A|2FA|
|requireReset|D||
|authProvider|L|AUTH_PROVIDER_PLUGIN|
### #__user_usergroup_map
|Source|M|X|
|---|:-:|---|
|user_id|L|USER|
|group_id|L|USERGROUP|
### #__viewlevels
|Source|M|X|
|---|:-:|---|
|id|L|VIEWLEVEL|
|title|D||
|ordering|D||
|rules|S|USERGROUP|
### #__user_profiles
|Source|M|X|
|---|:-:|---|
|user_id|L|USER|
|profile_key|D||
|profile_value|S|KEY_DEPENDENT_VALUE|
|ordering|D||
## G2
### #__assets
|Source|M|X|
|---|:-:|---|
|id|B||
|parent_id|B||
|lft|B||
|rgt|B||
|level|B||
|name|B||
|title|B||
|rules|B||
### #__categories
|Source|M|X|
|---|:-:|---|
|id|L|CATEGORY|
|asset_id|L|ASSET|
|parent_id|L|CATEGORY|
|lft|G|TREE|
|rgt|G|TREE|
|level|G|TREE|
|path|G|TREE|
|extension|L|EXTENSION_ELEMENT|
|title|D||
|alias|D||
|note|D||
|description|S|HTML_REFERENCE_SCAN|
|published|D||
|checked_out|L|USER|
|checked_out_time|T|DT|
|access|L|VIEWLEVEL|
|params|S|JOOMLA_REGISTRY/JSON|
|metadesc|D||
|metakey|D||
|metadata|S|JOOMLA_REGISTRY/JSON|
|created_user_id|L|USER|
|created_time|T|DT|
|modified_user_id|L|USER|
|modified_time|T|DT|
|hits|D||
|language|L|LANGUAGE|
|version|D||
### #__tags
|Source|M|X|
|---|:-:|---|
|id|L|TAG|
|parent_id|L|TAG|
|lft|G|TREE|
|rgt|G|TREE|
|level|G|TREE|
|path|G|TREE|
|title|D||
|alias|D||
|note|D||
|description|S|HTML_REFERENCE_SCAN|
|published|D||
|checked_out|L|USER|
|checked_out_time|T|DT|
|access|L|VIEWLEVEL|
|params|S|JOOMLA_REGISTRY/JSON|
|metadesc|D||
|metakey|D||
|metadata|S|JOOMLA_REGISTRY/JSON|
|created_user_id|L|USER|
|created_time|T|DT|
|created_by_alias|D||
|modified_user_id|L|USER|
|modified_time|T|DT|
|images|S|MEDIA_URL_JSON|
|urls|S|MEDIA_URL_JSON|
|hits|D||
|language|L|LANGUAGE|
|version|D||
|publish_up|T|DT|
|publish_down|T|DT|
### #__content_types
|Source|M|X|
|---|:-:|---|
|type_id|R||
|type_title|R||
|type_alias|R||
|table|R||
|rules|R||
|field_mappings|R||
|router|R||
|content_history_options|R||
### #__fields_groups
|Source|M|X|
|---|:-:|---|
|id|L|FIELD_GROUP|
|asset_id|L|ASSET|
|context|L|CONTENT_CONTEXT|
|title|D||
|note|D||
|description|S|HTML_REFERENCE_SCAN|
|state|D||
|checked_out|L|USER|
|checked_out_time|T|DT|
|ordering|D||
|params|S|JOOMLA_REGISTRY/JSON|
|language|L|LANGUAGE|
|created|T|DT|
|created_by|L|USER|
|modified|T|DT|
|modified_by|L|USER|
|access|L|VIEWLEVEL|
### #__fields
|Source|M|X|
|---|:-:|---|
|id|L|FIELD|
|asset_id|L|ASSET|
|context|L|CONTENT_CONTEXT|
|group_id|L|FIELD_GROUP|
|title|D||
|name|D||
|label|D||
|default_value|S|FIELD_TYPE_VALUE|
|type|D||
|note|D||
|description|S|HTML_REFERENCE_SCAN|
|state|D||
|required|D||
|checked_out|L|USER|
|checked_out_time|T|DT|
|ordering|D||
|params|S|JOOMLA_REGISTRY/JSON|
|fieldparams|S|JOOMLA_REGISTRY/JSON|
|language|L|LANGUAGE|
|created_time|T|DT|
|created_user_id|L|USER|
|modified_time|T|DT|
|modified_by|L|USER|
|access|L|VIEWLEVEL|
### #__fields_categories
|Source|M|X|
|---|:-:|---|
|field_id|L|FIELD|
|category_id|L|CATEGORY|
## G3
### #__content
|Source|M|X|
|---|:-:|---|
|id|L|CONTENT|
|asset_id|L|ASSET|
|title|D||
|alias|D||
|introtext|S|HTML_REFERENCE_SCAN|
|fulltext|S|HTML_REFERENCE_SCAN|
|state|T|WF|
|catid|L|CATEGORY|
|created|T|DT|
|created_by|L|USER|
|created_by_alias|D||
|modified|T|DT|
|modified_by|L|USER|
|checked_out|L|USER|
|checked_out_time|T|DT|
|publish_up|T|DT|
|publish_down|T|DT|
|images|S|MEDIA_URL_JSON|
|urls|S|MEDIA_URL_JSON|
|attribs|S|JOOMLA_REGISTRY/JSON|
|version|D||
|ordering|D||
|metakey|D||
|metadesc|D||
|access|L|VIEWLEVEL|
|hits|D||
|metadata|S|JOOMLA_REGISTRY/JSON|
|featured|T|FT|
|language|L|LANGUAGE|
|xreference|A||
|note|D||
### #__content_frontpage
|Source|M|X|
|---|:-:|---|
|content_id|L|CONTENT|
|ordering|D||
### #__content_rating
|Source|M|X|
|---|:-:|---|
|content_id|L|CONTENT|
|rating_sum|D||
|rating_count|D||
|lastip|D||
## G4
### #__contentitem_tag_map
|Source|M|X|
|---|:-:|---|
|type_alias|L|CONTENT_TYPE_ALIAS|
|core_content_id|B|UCM|
|content_item_id|L|ENTITY_BY_TYPE_ALIAS|
|tag_id|L|TAG|
|tag_date|T|DT|
|type_id|L|CONTENT_TYPE|
### #__fields_values
|Source|M|X|
|---|:-:|---|
|field_id|L|FIELD|
|item_id|L|ENTITY_BY_FIELD_CONTEXT|
|value|S|FIELD_PLUGIN|
### #__associations
|Source|M|X|
|---|:-:|---|
|id|L|ENTITY_BY_ASSOCIATION_CONTEXT|
|context|L|CONTENT_CONTEXT|
|key|T|AK|
### #__ucm_base
|Source|M|X|
|---|:-:|---|
|ucm_id|B||
|ucm_item_id|B||
|ucm_type_id|B||
|ucm_language_id|B||
### #__ucm_content
|Source|M|X|
|---|:-:|---|
|core_content_id|B||
|core_type_alias|B||
|core_title|B||
|core_alias|B||
|core_body|B||
|core_state|B||
|core_checked_out_time|B||
|core_checked_out_user_id|B||
|core_access|B||
|core_params|B||
|core_featured|B||
|core_metadata|B||
|core_created_user_id|B||
|core_created_by_alias|B||
|core_created_time|B||
|core_modified_user_id|B||
|core_modified_time|B||
|core_language|B||
|core_publish_up|B||
|core_publish_down|B||
|core_content_item_id|B||
|asset_id|B||
|core_images|B||
|core_urls|B||
|core_hits|B||
|core_version|B||
|core_ordering|B||
|core_metakey|B||
|core_metadesc|B||
|core_catid|B||
|core_xreference|B||
|core_type_id|B||
### #__ucm_history
|Source|M|X|
|---|:-:|---|
|version_id|D||
|ucm_item_id|T|HID|
|ucm_type_id|T|HID|
|version_note|D||
|save_date|T|DT|
|editor_user_id|L|USER|
|character_count|D||
|sha1_hash|D||
|version_data|S|HISTORY_SNAPSHOT|
|keep_forever|D||
## G5
### #__template_styles
|Source|M|X|
|---|:-:|---|
|id|L|TEMPLATE_STYLE|
|template|L|TEMPLATE_ELEMENT|
|client_id|D||
|home|D||
|title|D||
|inheritable|D||
|parent|D||
|params|S|JOOMLA_REGISTRY/JSON|
### #__menu_types
|Source|M|X|
|---|:-:|---|
|id|L|MENU_TYPE|
|asset_id|L|ASSET|
|menutype|D||
|title|D||
|description|D||
|client_id|D||
### #__menu
|Source|M|X|
|---|:-:|---|
|id|L|MENU|
|menutype|L|MENU_TYPE_KEY|
|title|D||
|alias|D||
|note|D||
|path|G|TREE|
|link|S|QUERY_STRING_WITH_IDS|
|type|D||
|published|D||
|parent_id|L|MENU|
|level|G|TREE|
|component_id|L|EXTENSION|
|checked_out|L|USER|
|checked_out_time|T|DT|
|browserNav|D||
|access|L|VIEWLEVEL|
|img|S|MEDIA_PATH|
|template_style_id|L|TEMPLATE_STYLE|
|params|S|JOOMLA_REGISTRY/JSON|
|lft|G|TREE|
|rgt|G|TREE|
|home|D||
|language|L|LANGUAGE|
|client_id|D||
## G6
### #__modules
|Source|M|X|
|---|:-:|---|
|id|L|MODULE|
|asset_id|L|ASSET|
|title|D||
|note|D||
|content|S|HTML_REFERENCE_SCAN|
|ordering|D||
|position|D||
|checked_out|L|USER|
|checked_out_time|T|DT|
|publish_up|T|DT|
|publish_down|T|DT|
|published|D||
|module|L|EXTENSION_ELEMENT|
|access|L|VIEWLEVEL|
|showtitle|D||
|params|S|JOOMLA_REGISTRY/JSON|
|client_id|D||
|language|L|LANGUAGE|
### #__modules_menu
|Source|M|X|
|---|:-:|---|
|moduleid|L|MODULE|
|menuid|L|MENU_SENTINEL|
## G7
### #__contact_details
|Source|M|X|
|---|:-:|---|
|id|L|CONTACT|
|name|D||
|alias|D||
|con_position|D||
|address|D||
|suburb|D||
|state|D||
|country|D||
|postcode|D||
|telephone|D||
|fax|D||
|misc|S|HTML_REFERENCE_SCAN|
|image|S|MEDIA_PATH|
|email_to|D||
|default_con|D||
|published|D||
|checked_out|L|USER|
|checked_out_time|T|DT|
|ordering|D||
|params|S|JOOMLA_REGISTRY/JSON|
|user_id|L|USER|
|catid|L|CATEGORY|
|access|L|VIEWLEVEL|
|mobile|D||
|webpage|S|URL|
|sortname1|D||
|sortname2|D||
|sortname3|D||
|language|L|LANGUAGE|
|created|T|DT|
|created_by|L|USER|
|created_by_alias|D||
|modified|T|DT|
|modified_by|L|USER|
|metakey|D||
|metadesc|D||
|metadata|S|JOOMLA_REGISTRY/JSON|
|featured|D||
|xreference|A||
|publish_up|T|DT|
|publish_down|T|DT|
|version|D||
|hits|D||
### #__newsfeeds
|Source|M|X|
|---|:-:|---|
|catid|L|CATEGORY|
|id|L|NEWSFEED|
|name|D||
|alias|D||
|link|S|URL|
|published|D||
|numarticles|D||
|cache_time|D||
|checked_out|L|USER|
|checked_out_time|T|DT|
|ordering|D||
|rtl|D||
|access|L|VIEWLEVEL|
|language|L|LANGUAGE|
|params|S|JOOMLA_REGISTRY/JSON|
|created|T|DT|
|created_by|L|USER|
|created_by_alias|D||
|modified|T|DT|
|modified_by|L|USER|
|metakey|D||
|metadesc|D||
|metadata|S|JOOMLA_REGISTRY/JSON|
|xreference|A||
|publish_up|T|DT|
|publish_down|T|DT|
|description|S|HTML_REFERENCE_SCAN|
|version|D||
|hits|D||
|images|S|MEDIA_URL_JSON|
### #__banners
|Source|M|X|
|---|:-:|---|
|id|L|BANNER|
|cid|L|BANNER_CLIENT|
|type|D||
|name|D||
|alias|D||
|imptotal|D||
|impmade|D||
|clicks|D||
|clickurl|S|URL|
|state|D||
|catid|L|CATEGORY|
|description|S|HTML_REFERENCE_SCAN|
|custombannercode|S|HTML_REFERENCE_SCAN|
|sticky|D||
|ordering|D||
|metakey|D||
|params|S|JOOMLA_REGISTRY/JSON|
|own_prefix|D||
|metakey_prefix|D||
|purchase_type|D||
|track_clicks|D||
|track_impressions|D||
|checked_out|L|USER|
|checked_out_time|T|DT|
|publish_up|T|DT|
|publish_down|T|DT|
|reset|T|DT|
|created|T|DT|
|language|L|LANGUAGE|
|created_by|L|USER|
|created_by_alias|D||
|modified|T|DT|
|modified_by|L|USER|
|version|D||
### #__banner_clients
|Source|M|X|
|---|:-:|---|
|id|L|BANNER_CLIENT|
|name|D||
|contact|D||
|email|D||
|extrainfo|D||
|state|D||
|checked_out|L|USER|
|checked_out_time|T|DT|
|metakey|D||
|own_prefix|D||
|metakey_prefix|D||
|purchase_type|D||
|track_clicks|D||
|track_impressions|D||
### #__banner_tracks
|Source|M|X|
|---|:-:|---|
|track_date|A||
|track_type|A||
|banner_id|A||
|count|A||
### #__redirect_links
|Source|M|X|
|---|:-:|---|
|id|L|REDIRECT|
|old_url|S|URL|
|new_url|S|URL|
|referer|S|URL|
|comment|D||
|hits|D||
|published|D||
|created_date|T|DT|
|modified_date|T|DT|
|header|D||
### #__messages
|Source|M|X|
|---|:-:|---|
|message_id|L|MESSAGE|
|user_id_from|L|USER|
|user_id_to|L|USER|
|folder_id|D||
|date_time|T|DT|
|state|D||
|priority|D||
|subject|D||
|message|S|HTML_REFERENCE_SCAN|
### #__messages_cfg
|Source|M|X|
|---|:-:|---|
|user_id|L|USER|
|cfg_name|D||
|cfg_value|S|KEY_DEPENDENT_VALUE|
### #__user_notes
|Source|M|X|
|---|:-:|---|
|id|L|USER_NOTE|
|user_id|L|USER|
|catid|L|CATEGORY|
|subject|D||
|body|S|HTML_REFERENCE_SCAN|
|state|D||
|checked_out|L|USER|
|checked_out_time|T|DT|
|created_user_id|L|USER|
|created_time|T|DT|
|modified_user_id|L|USER|
|modified_time|T|DT|
|review_time|T|DT|
|publish_up|T|DT|
|publish_down|T|DT|
### #__privacy_requests
|Source|M|X|
|---|:-:|---|
|id|L|PRIVACY_REQUEST|
|email|D||
|requested_at|T|DT|
|status|D||
|request_type|D||
|confirm_token|T|PT|
|confirm_token_created_at|T|DT|
### #__privacy_consents
|Source|M|X|
|---|:-:|---|
|id|L|PRIVACY_CONSENT|
|user_id|L|USER|
|state|D||
|created|T|DT|
|subject|D||
|body|S|HTML_REFERENCE_SCAN|
|remind|D||
|token|T|PT|
### #__action_logs_extensions
|Source|M|X|
|---|:-:|---|
|id|R||
|extension|R||
### #__action_log_config
|Source|M|X|
|---|:-:|---|
|id|R||
|type_title|R||
|type_alias|R||
|id_holder|R||
|title_holder|R||
|table_name|R||
|text_prefix|R||
### #__action_logs_users
|Source|M|X|
|---|:-:|---|
|user_id|L|USER|
|notify|D||
|extensions|S|EXTENSION_LIST|
## G8
### #__session
|Source|M|X|
|---|:-:|---|
|session_id|I||
|client_id|I||
|guest|I||
|time|I||
|data|I||
|userid|I||
|username|I||
### #__user_keys
|Source|M|X|
|---|:-:|---|
|id|I||
|user_id|I||
|token|I||
|series|I||
|invalid|I||
|time|I||
|uastring|I||
### #__finder_filters
|Source|M|X|
|---|:-:|---|
|filter_id|L|FINDER_FILTER|
|title|D||
|alias|D||
|state|D||
|created|T|DT|
|created_by|L|USER|
|created_by_alias|D||
|modified|T|DT|
|modified_by|L|USER|
|checked_out|L|USER|
|checked_out_time|T|DT|
|map_count|G|FM|
|data|S|FINDER_FILTER_DATA|
|params|S|JOOMLA_REGISTRY/JSON|
### #__finder_links
|Source|M|X|
|---|:-:|---|
|link_id|B||
|url|B||
|route|B||
|title|B||
|description|B||
|indexdate|B||
|md5sum|B||
|published|B||
|state|B||
|access|B||
|language|B||
|publish_start_date|B||
|publish_end_date|B||
|start_date|B||
|end_date|B||
|list_price|B||
|sale_price|B||
|type_id|B||
|object|B||
### #__finder_links_terms0
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms1
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms2
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms3
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms4
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms5
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms6
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms7
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms8
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms9
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_termsa
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_termsb
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_termsc
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_termsd
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_termse
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_termsf
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_taxonomy
|Source|M|X|
|---|:-:|---|
|id|B||
|parent_id|B||
|title|B||
|state|B||
|access|B||
|ordering|B||
### #__finder_taxonomy_map
|Source|M|X|
|---|:-:|---|
|link_id|B||
|node_id|B||
### #__finder_terms
|Source|M|X|
|---|:-:|---|
|term_id|B||
|term|B||
|stem|B||
|common|B||
|phrase|B||
|weight|B||
|soundex|B||
|links|B||
|language|B||
### #__finder_terms_common
|Source|M|X|
|---|:-:|---|
|term|D||
|language|L|LANGUAGE|
### #__finder_tokens
|Source|M|X|
|---|:-:|---|
|term|B||
|stem|B||
|common|B||
|phrase|B||
|weight|B||
|context|B||
|language|B||
### #__finder_tokens_aggregate
|Source|M|X|
|---|:-:|---|
|term_id|B||
|map_suffix|B||
|term|B||
|stem|B||
|common|B||
|phrase|B||
|term_weight|B||
|context|B||
|context_weight|B||
|total_weight|B||
|language|B||
### #__finder_types
|Source|M|X|
|---|:-:|---|
|id|B||
|title|B||
|mime|B||
### #__action_logs
|Source|M|X|
|---|:-:|---|
|id|A||
|message_language_key|A||
|message|A||
|log_date|A||
|extension|A||
|user_id|A||
|item_id|A||
|ip_address|A||
### #__core_log_searches
|Source|M|X|
|---|:-:|---|
|search_term|A||
|hits|A||
### #__overrider
|Source|M|X|
|---|:-:|---|
|id|L|LANGUAGE_OVERRIDE|
|constant|D||
|string|D||
|file|S|FILE_PATH|
### #__postinstall_messages
|Source|M|X|
|---|:-:|---|
|postinstall_message_id|I||
|extension_id|I||
|title_key|I||
|description_key|I||
|action_key|I||
|language_extension|I||
|language_client_id|I||
|type|I||
|action_file|I||
|action|I||
|condition_file|I||
|condition_method|I||
|version_introduced|I||
|enabled|I||
### #__utf8_conversion
|Source|M|X|
|---|:-:|---|
|converted|I||

# Target anti-join

`QA against joomla-core-migration-fields-v6.md: 76/76 target tables and 832/832 target fields resolved; unknown strategy=0; unresolved required target=0.`

Target field is same-name within the destination table except: `extensions.system_data→-`; `users.otpKey/otep→-`; `content.xreference→-`; `ucm_content.core_xreference→-`; `ucm_history.ucm_item_id→history.item_id`; `ucm_history.ucm_type_id→history.item_id`; `contact_details.xreference→-`; `newsfeeds.xreference→-`; `finder_taxonomy.ordering→-`; `finder_tokens_aggregate.map_suffix→-`. Added/synthesized target fields and target-only/recreated structures are resolved by the J6 anti-join strategy from the canonical V6 field manifest and `table-mapping-migration.md`.

# Case / seed gate

Covers IDs via `value_mapping`; sentinel and polymorphic references; JSON/Registry/ACL/HTML/URL/query/media/path/field values; zero-date/null/default; trees; PK/composite/unique/collision/truncation/range/signedness/collation; session/user_keys/password/legacy 2FA; UCM/Finder rebuild; menus; custom fields; associations/tags; privacy; workflow generation. Raw string ID replacement and secret logging are forbidden. Source-only explicit outcomes: `extensions.system_data`, content/contact/newsfeeds `xreference`=A; `ucm_content.core_xreference`, `finder_tokens_aggregate.map_suffix`=B; `user_keys.invalid`=I.

Seed `migration_mapping.field_mapping` using unique `(source_version,source_table,source_field)`; IDs/values stay in `value_mapping`; dependencies remain in existing inventory; no extra contract table.

```sql
SELECT COUNT(*) rows,COUNT(DISTINCT CONCAT(source_table,'.',source_field)) uniq FROM migration_mapping.field_mapping WHERE source_version='3.10.12';
```
Expected `711/711`.

```text
FIELD MAPPING CONTRACT = PASS (definition-level)
J3 rows/unique=711/711; missing/duplicate=0/0; table join=711/711
L missing domain/context=0; S missing parser=0; silent drops=0
J6 tables/fields=76/76,832/832; unknown/unresolved target=0
unsafe direct/truncation/collision/dependency allowed=0
```

> Production PASS requires actual-schema reconciliation, real mapping materialization, runtime `value_mapping`, row accounting and zero migration/verification errors.

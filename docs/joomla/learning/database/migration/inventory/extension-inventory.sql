SELECT extension_id, type, element, folder, client_id, enabled, protected, state, manifest_cache
FROM joomla3_source.j3_extensions
ORDER BY type, element, folder, client_id;

-- Map extensions by: type + element + folder + client_id.

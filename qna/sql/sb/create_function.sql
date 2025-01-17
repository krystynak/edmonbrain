CREATE OR REPLACE FUNCTION match_documents_{vector_name}(query_embedding vector({vector_size}), match_count int)
           RETURNS TABLE(
               id uuid,
               content text,
               metadata jsonb,
               -- we return matched vectors to enable maximal marginal relevance searches
               embedding vector({vector_size}),
               similarity float)
           LANGUAGE plpgsql
           AS $$
           # variable_conflict use_column
       BEGIN
           RETURN query
           SELECT
               id,
               content,
               metadata,
               embedding,
               1 -({vector_name}.embedding <=> query_embedding) AS similarity
           FROM
               {vector_name}
           where 1 - ({vector_name}.embedding <=> query_embedding) > 0.6
           ORDER BY
               {vector_name}.embedding <=> query_embedding
           LIMIT match_count;
       END;
       $$;
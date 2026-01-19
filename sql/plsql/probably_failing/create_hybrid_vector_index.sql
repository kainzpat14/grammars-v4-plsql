-- CREATE HYBRID VECTOR INDEX statement examples
-- This statement is not currently supported by the PlSql grammar
-- Hybrid Vector indexes were introduced in Oracle 23ai release 23.6
-- Combines full-text search with vector similarity search

-- Basic hybrid vector index with minimum required parameters
CREATE HYBRID VECTOR INDEX my_hybrid_idx
ON doc_table(text_column)
PARAMETERS('MODEL my_embed_model');

-- Hybrid vector index with memory and parallel options
CREATE HYBRID VECTOR INDEX my_hybrid_idx
ON doc_table(text_column)
PARAMETERS('MODEL my_embed_model MEMORY 1G')
PARALLEL 4;

-- Hybrid vector index with HNSW vector index type
CREATE HYBRID VECTOR INDEX my_hybrid_idx_hnsw
ON ccnews_1(info)
PARAMETERS ('model doc_model vector_idxtype HNSW')
PARALLEL 8;

-- Simple hybrid index with model only
CREATE HYBRID VECTOR INDEX ccnews_hybrid_idx
ON ccnews(info)
PARAMETERS ('model doc_model')
PARALLEL 8;

-- Hybrid vector index with text search preferences
CREATE HYBRID VECTOR INDEX comprehensive_hybrid_idx
ON doc_table(text_column)
PARAMETERS('MODEL my_doc_model
           DATASTORE my_datastore
           STORAGE my_storage
           STOPLIST my_stoplist
           LEXER my_lexer')
ORDER BY docid ASC;

-- Real-world example: Wine reviews
CREATE HYBRID VECTOR INDEX wine_reviews_hybrid_idx
ON WineReviews130K(description)
PARAMETERS ('MODEL all_minilm_l12_v2');

-- Hybrid vector index with IVF vector index type (default)
CREATE HYBRID VECTOR INDEX products_hybrid_idx
ON products(description)
PARAMETERS ('model product_embedding_model vector_idxtype IVF')
PARALLEL 4;

-- Hybrid vector index on CLOB column
CREATE HYBRID VECTOR INDEX articles_hybrid_idx
ON articles(content)
PARAMETERS ('model article_embed_model MEMORY 2G')
PARALLEL 8;

-- Hybrid vector index with custom chunking parameters
CREATE HYBRID VECTOR INDEX docs_hybrid_idx
ON documents(doc_content)
PARAMETERS ('model doc_embedding
           chunk_size 500
           chunk_overlap 50
           MEMORY 1G')
PARALLEL 4;

-- Hybrid vector index on multiple text columns
CREATE HYBRID VECTOR INDEX multi_col_hybrid_idx
ON content_table(title || ' ' || body)
PARAMETERS ('model content_model')
PARALLEL 4;

-- With schema qualification
CREATE HYBRID VECTOR INDEX myschema.docs_hybrid_idx
ON myschema.documents(text_content)
PARAMETERS ('model myschema.doc_model');

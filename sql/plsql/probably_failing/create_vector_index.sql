-- CREATE VECTOR INDEX statement examples
-- This statement is not currently supported by the PlSql grammar
-- Vector indexes were introduced in Oracle 23ai for AI Vector Search

-- IVF (Inverted File Flat) Index - Neighbor Partition Vector Index
-- Basic IVF index with COSINE distance
CREATE VECTOR INDEX movie_quotes_vector_idx
ON movie_quotes(movie_quote_vector)
ORGANIZATION NEIGHBOR PARTITIONS
DISTANCE COSINE
WITH TARGET ACCURACY 95;

-- IVF index with default distance metric (COSINE)
CREATE VECTOR INDEX docs_ivf_idx
ON documents (embedding)
ORGANIZATION NEIGHBOR PARTITIONS
WITH TARGET ACCURACY 90;

-- IVF index with EUCLIDEAN distance
CREATE VECTOR INDEX products_vector_idx
ON products(product_embedding)
ORGANIZATION NEIGHBOR PARTITIONS
DISTANCE EUCLIDEAN
WITH TARGET ACCURACY 92;

-- IVF index with DOT distance
CREATE VECTOR INDEX articles_vector_idx
ON articles(article_vector)
ORGANIZATION NEIGHBOR PARTITIONS
DISTANCE DOT
WITH TARGET ACCURACY 85;

-- Simple IVF index without target accuracy
CREATE VECTOR INDEX example_ivf_idx
ON second_table (embedding5)
ORGANIZATION NEIGHBOR PARTITIONS;

-- HNSW (Hierarchical Navigable Small World) Index - In-Memory Neighbor Graph
-- Basic HNSW index
CREATE VECTOR INDEX movie_quotes_hnsw_idx
ON movie_quotes(movie_quote_vector)
ORGANIZATION INMEMORY NEIGHBOR GRAPH
DISTANCE COSINE
WITH TARGET ACCURACY 95;

-- HNSW index with EUCLIDEAN distance
CREATE VECTOR INDEX galaxies_hnsw_idx
ON galaxies (embedding)
ORGANIZATION INMEMORY NEIGHBOR GRAPH
DISTANCE EUCLIDEAN;

-- HNSW index without target accuracy
CREATE VECTOR INDEX simple_hnsw_idx
ON vectors_table(vec_column)
ORGANIZATION INMEMORY NEIGHBOR GRAPH
DISTANCE COSINE;

-- Vector index with schema qualification
CREATE VECTOR INDEX myschema.documents_vec_idx
ON myschema.documents(doc_embedding)
ORGANIZATION NEIGHBOR PARTITIONS
DISTANCE COSINE
WITH TARGET ACCURACY 90;

-- Multiple vector indexes on different columns
CREATE VECTOR INDEX text_embedding_idx
ON content(text_embedding)
ORGANIZATION NEIGHBOR PARTITIONS
DISTANCE COSINE
WITH TARGET ACCURACY 95;

CREATE VECTOR INDEX image_embedding_idx
ON content(image_embedding)
ORGANIZATION INMEMORY NEIGHBOR GRAPH
DISTANCE EUCLIDEAN
WITH TARGET ACCURACY 90;

-- Vector index with L1 (Manhattan) distance
CREATE VECTOR INDEX l1_distance_idx
ON vectors(vec_data)
ORGANIZATION NEIGHBOR PARTITIONS
DISTANCE MANHATTAN
WITH TARGET ACCURACY 88;

-- Vector index with L2 (Euclidean) distance - explicit
CREATE VECTOR INDEX l2_distance_idx
ON vectors(vec_data)
ORGANIZATION NEIGHBOR PARTITIONS
DISTANCE L2
WITH TARGET ACCURACY 90;

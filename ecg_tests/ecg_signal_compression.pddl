;; ecg_signal_compression.pddl - ECG signal compression with quality assessment
(define (problem ecg_signal_compression)
  (:domain biosignal-pipelines)

  ;; === OBJECT DECLARATIONS ===
  (:objects
    ;; Data types
    ts - timeseries
    seg - segments
    feat - features
    sc - scalar
    
    ;; Block instances
    bandpass_filter_05_100hz - block
    qrs_heartbeat_segmenter - block
    rpeak_aligner - block
    pca_dimensionality_reducer - block
    wavelet_encoder - block
    sparse_coder - block
    huffman_compressor - block
    prd_quality_assessor - block
    median_filter - block
    artifact_detector - block
    feature_selector - block
    normalizer - block
    correlation_calculator - block
    risk_scorer - block
    
    ;; Block types
    filter_type - filter
    segmenter_type - segmenter
    extractor_type - extractor
    aggregator_type - aggregator
    
    ;; Pipeline slots
    slot1 slot2 slot3 slot4 slot5 slot6 slot7 slot8 - pipeline-slot
    
    ;; Purposes
    bandpass-filtering beat-alignment heartbeat-segmentation huffman-compression pca-reduction quality-evaluation sparse-coding wavelet-encoding - object
  )

  ;; === INITIAL STATE ===
  (:init
    ;; Mark which slots are part of this pipeline
    (pipeline-slot slot1)
    (pipeline-slot slot2)
    (pipeline-slot slot3)
    (pipeline-slot slot4)
    (pipeline-slot slot5)
    (pipeline-slot slot6)
    (pipeline-slot slot7)
    (pipeline-slot slot8)

    ;; Pipeline connections
    (slot-connected slot1 slot2)
    (slot-connected slot2 slot3)
    (slot-connected slot3 slot4)
    (slot-connected slot4 slot5)
    (slot-connected slot5 slot6)
    (slot-connected slot6 slot7)
    (slot-connected slot7 slot8)

    ;; Next-slot relationships
    (next-slot slot1 slot2)
    (next-slot slot2 slot3)
    (next-slot slot3 slot4)
    (next-slot slot4 slot5)
    (next-slot slot5 slot6)
    (next-slot slot6 slot7)
    (next-slot slot7 slot8)

    ;; Data flow requirements for each slot
    (slot-requires-input slot1 ts)
    (slot-requires-output slot1 ts)
    (slot-purpose slot1 bandpass-filtering)

    (slot-requires-input slot2 ts)
    (slot-requires-output slot2 seg)
    (slot-purpose slot2 heartbeat-segmentation)

    (slot-requires-input slot3 seg)
    (slot-requires-output slot3 feat)
    (slot-purpose slot3 beat-alignment)

    (slot-requires-input slot4 feat)
    (slot-requires-output slot4 feat)
    (slot-purpose slot4 pca-reduction)

    (slot-requires-input slot5 feat)
    (slot-requires-output slot5 feat)
    (slot-purpose slot5 wavelet-encoding)

    (slot-requires-input slot6 feat)
    (slot-requires-output slot6 feat)
    (slot-purpose slot6 sparse-coding)

    (slot-requires-input slot7 feat)
    (slot-requires-output slot7 feat)
    (slot-purpose slot7 huffman-compression)

    (slot-requires-input slot8 feat)
    (slot-requires-output slot8 sc)
    (slot-purpose slot8 quality-evaluation)

    ;; === AVAILABLE BLOCKS ===

    ;; bandpass_filter_05_100hz: Bandpass filter 0.5-100 Hz
    (block-type bandpass_filter_05_100hz filter_type)
    (available bandpass_filter_05_100hz)
    (purpose-match bandpass_filter_05_100hz bandpass-filtering)
    (valid-parameter-values bandpass_filter_05_100hz)

    ;; qrs_heartbeat_segmenter: QRS-based heartbeat segmentation
    (block-type qrs_heartbeat_segmenter segmenter_type)
    (available qrs_heartbeat_segmenter)
    (purpose-match qrs_heartbeat_segmenter heartbeat-segmentation)
    (valid-parameter-values qrs_heartbeat_segmenter)

    ;; rpeak_aligner: R-peak based beat alignment
    (block-type rpeak_aligner extractor_type)
    (available rpeak_aligner)
    (purpose-match rpeak_aligner beat-alignment)
    (valid-parameter-values rpeak_aligner)

    ;; pca_dimensionality_reducer: PCA dimensionality reduction
    (block-type pca_dimensionality_reducer extractor_type)
    (available pca_dimensionality_reducer)
    (purpose-match pca_dimensionality_reducer pca-reduction)
    (valid-parameter-values pca_dimensionality_reducer)

    ;; wavelet_encoder: Discrete wavelet transform encoder
    (block-type wavelet_encoder extractor_type)
    (available wavelet_encoder)
    (purpose-match wavelet_encoder wavelet-encoding)
    (valid-parameter-values wavelet_encoder)

    ;; sparse_coder: Sparse coding with thresholding
    (block-type sparse_coder extractor_type)
    (available sparse_coder)
    (purpose-match sparse_coder sparse-coding)
    (valid-parameter-values sparse_coder)

    ;; huffman_compressor: Huffman encoding compression
    (block-type huffman_compressor extractor_type)
    (available huffman_compressor)
    (purpose-match huffman_compressor huffman-compression)
    (valid-parameter-values huffman_compressor)

    ;; prd_quality_assessor: PRD quality assessment
    (block-type prd_quality_assessor aggregator_type)
    (available prd_quality_assessor)
    (purpose-match prd_quality_assessor quality-evaluation)
    (valid-parameter-values prd_quality_assessor)

    ;; median_filter: Median filter
    (block-type median_filter filter_type)
    (available median_filter)
    (valid-parameter-values median_filter)

    ;; artifact_detector: Artifact detection
    (block-type artifact_detector extractor_type)
    (available artifact_detector)
    (valid-parameter-values artifact_detector)

    ;; feature_selector: Feature selection
    (block-type feature_selector extractor_type)
    (available feature_selector)
    (valid-parameter-values feature_selector)

    ;; normalizer: Signal normalization
    (block-type normalizer extractor_type)
    (available normalizer)
    (valid-parameter-values normalizer)

    ;; correlation_calculator: Correlation calculator
    (block-type correlation_calculator aggregator_type)
    (available correlation_calculator)
    (valid-parameter-values correlation_calculator)

    ;; risk_scorer: Clinical risk scorer
    (block-type risk_scorer aggregator_type)
    (available risk_scorer)
    (valid-parameter-values risk_scorer)

    ;; Block type capabilities
    (input-type filter_type ts)
    (output-type filter_type ts)
    
    (input-type segmenter_type ts)
    (output-type segmenter_type seg)
    
    (input-type extractor_type seg)
    (output-type extractor_type feat)
    
    (input-type aggregator_type feat)
    (output-type aggregator_type sc)

  )

  ;; === GOAL ===
  (:goal (and 
    (pipeline-complete)
    (data-flow-valid)
  ))
)
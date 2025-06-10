;; ecg_basic_hr_detection.pddl - Basic ECG heart rate detection with artifact flagging
(define (problem ecg_basic_hr_detection)
  (:domain biosignal-pipelines)

  ;; === OBJECT DECLARATIONS ===
  (:objects
    ;; Data types
    ts - timeseries
    seg - segments
    feat - features
    sc - scalar
    
    ;; Block instances
    bandpass_filter_05_40hz - block
    notch_filter_50_60hz - block
    wavelet_denoiser - block
    pan_tompkins_detector - block
    rpeak_identifier - block
    hr_calculator - block
    abnormal_beat_flagger - block
    high_pass_filter - block
    pca_reducer - block
    fourier_transformer - block
    ml_classifier - block
    signal_averager - block
    
    ;; Block types
    filter_type - filter
    segmenter_type - segmenter
    extractor_type - extractor
    aggregator_type - aggregator
    
    ;; Pipeline slots
    slot1 slot2 slot3 slot4 slot5 slot6 slot7 - pipeline-slot
    
    ;; Purposes
    abnormal-beat-flagging bandpass-filtering hr-calculation notch-filtering qrs-detection rpeak-identification wavelet-denoising - object
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

    ;; Pipeline connections
    (slot-connected slot1 slot2)
    (slot-connected slot2 slot3)
    (slot-connected slot3 slot4)
    (slot-connected slot4 slot5)
    (slot-connected slot5 slot6)
    (slot-connected slot6 slot7)

    ;; Next-slot relationships
    (next-slot slot1 slot2)
    (next-slot slot2 slot3)
    (next-slot slot3 slot4)
    (next-slot slot4 slot5)
    (next-slot slot5 slot6)
    (next-slot slot6 slot7)

    ;; Data flow requirements for each slot
    (slot-requires-input slot1 ts)
    (slot-requires-output slot1 ts)
    (slot-purpose slot1 bandpass-filtering)

    (slot-requires-input slot2 ts)
    (slot-requires-output slot2 ts)
    (slot-purpose slot2 notch-filtering)

    (slot-requires-input slot3 ts)
    (slot-requires-output slot3 ts)
    (slot-purpose slot3 wavelet-denoising)

    (slot-requires-input slot4 ts)
    (slot-requires-output slot4 seg)
    (slot-purpose slot4 qrs-detection)

    (slot-requires-input slot5 seg)
    (slot-requires-output slot5 feat)
    (slot-purpose slot5 rpeak-identification)

    (slot-requires-input slot6 feat)
    (slot-requires-output slot6 feat)
    (slot-purpose slot6 hr-calculation)

    (slot-requires-input slot7 feat)
    (slot-requires-output slot7 feat)
    (slot-purpose slot7 abnormal-beat-flagging)

    ;; === AVAILABLE BLOCKS ===

    ;; bandpass_filter_05_40hz: Bandpass filter 0.5-40 Hz
    (block-type bandpass_filter_05_40hz filter_type)
    (available bandpass_filter_05_40hz)
    (purpose-match bandpass_filter_05_40hz bandpass-filtering)
    (valid-parameter-values bandpass_filter_05_40hz)

    ;; notch_filter_50_60hz: Power line notch filter
    (block-type notch_filter_50_60hz filter_type)
    (available notch_filter_50_60hz)
    (purpose-match notch_filter_50_60hz notch-filtering)
    (valid-parameter-values notch_filter_50_60hz)

    ;; wavelet_denoiser: Wavelet-based denoising
    (block-type wavelet_denoiser filter_type)
    (available wavelet_denoiser)
    (purpose-match wavelet_denoiser wavelet-denoising)
    (valid-parameter-values wavelet_denoiser)

    ;; pan_tompkins_detector: Pan-Tompkins QRS detector
    (block-type pan_tompkins_detector segmenter_type)
    (available pan_tompkins_detector)
    (purpose-match pan_tompkins_detector qrs-detection)
    (valid-parameter-values pan_tompkins_detector)

    ;; rpeak_identifier: R-peak identification
    (block-type rpeak_identifier extractor_type)
    (available rpeak_identifier)
    (purpose-match rpeak_identifier rpeak-identification)
    (valid-parameter-values rpeak_identifier)

    ;; hr_calculator: Heart rate calculator
    (block-type hr_calculator extractor_type)
    (available hr_calculator)
    (purpose-match hr_calculator hr-calculation)
    (valid-parameter-values hr_calculator)

    ;; abnormal_beat_flagger: Abnormal beat detection
    (block-type abnormal_beat_flagger extractor_type)
    (available abnormal_beat_flagger)
    (purpose-match abnormal_beat_flagger abnormal-beat-flagging)
    (valid-parameter-values abnormal_beat_flagger)

    ;; high_pass_filter: High-pass filter (irrelevant)
    (block-type high_pass_filter filter_type)
    (available high_pass_filter)
    (valid-parameter-values high_pass_filter)

    ;; pca_reducer: PCA dimensionality reduction
    (block-type pca_reducer extractor_type)
    (available pca_reducer)
    (valid-parameter-values pca_reducer)

    ;; fourier_transformer: FFT transformer
    (block-type fourier_transformer extractor_type)
    (available fourier_transformer)
    (valid-parameter-values fourier_transformer)

    ;; ml_classifier: Machine learning classifier
    (block-type ml_classifier aggregator_type)
    (available ml_classifier)
    (valid-parameter-values ml_classifier)

    ;; signal_averager: Signal averaging block
    (block-type signal_averager aggregator_type)
    (available signal_averager)
    (valid-parameter-values signal_averager)

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
% Use edfmex to convert .edf files to data structure for
% ET-remove-artifacts


files = dir(fullfile('results','*.edf'));

for file_num = 1:numel(files)
    S=[];
    
    V = edfmex(fullfile(files(file_num).folder, files(file_num).name));
    
    start_times = [V.RECORDINGS([V.RECORDINGS.state] == 1).time];
    end_times = [V.RECORDINGS([V.RECORDINGS.state] == 0).time];
    
    %% segment data (15 or 10 runs) and format data structure to be compatible with ET-remove-artifacts
    for eye_num = 1:2
        % eye_num == 1 is left eye; eye_num == 2 is right eye
        if eye_num == 1
            eye = 'left';
        elseif eye_num == 2
            eye = 'right';
        end
        
        output_filename = fullfile('pupil_data', ['pupil_step-1_eye-' eye '_sub-' files(file_num).name '.mat']);
        if exist(output_filename, 'file')
            continue
        end
        
        for S_num = 1:numel(start_times)
            S(S_num).data.smp_timestamp = double(V.FSAMPLE.time(V.FSAMPLE.time > start_times(S_num) & V.FSAMPLE.time < end_times(S_num))')/1000;
            
            % column 1 is left eye; col 2 is right eye (specified by eye_num)
            S(S_num).data.sample = double(V.FSAMPLE.pa(eye_num,V.FSAMPLE.time > start_times(S_num) & V.FSAMPLE.time < end_times(S_num))');
            
            %% Filter parameters:
            S(S_num).filter_config.sub_nums = 1;
            S(S_num).filter_config.resample_rate = 1000;
            S(S_num).filter_config.resample_multiplier = 1;
            S(S_num).filter_config.detect_blinks = 1;
            S(S_num).filter_config.filter_order = 100;       % just going to use 30% of sample rate rule of thumb
            S(S_num).filter_config.peak_boundary_threshold = 0;
            S(S_num).filter_config.trough_boundary_threshold = 0;
            S(S_num).filter_config.passband_freq = 1;
            S(S_num).filter_config.stopband_freq = 40;
            S(S_num).filter_config.peak_threshold_factor = 5;
            S(S_num).filter_config.trough_threshold_factor = 5;
            S(S_num).filter_config.detect_invalid_samples = 0;
            S(S_num).filter_config.front_padding = .1;
            S(S_num).filter_config.rear_padding = .1;
            S(S_num).filter_config.merge_invalids_gap = 0;
            S(S_num).filter_config.merge_artifacts_gap = 0.2;
            S(S_num).filter_config.max_artifact_duration = 2;
            S(S_num).filter_config.max_artifact_treatment = 'NaN Impute';
        end
        
        save(output_filename,'S');
    end
end
function [time_start, time_end, strt_ind, end_ind, time_downs, pore_downs, ind_downs] = fncRangeSelector(time, pore)
% Validate inputs
if length(time) ~= length(pore)
    error('Time and pore vectors must be of the same length.');
end

% Create figure and axes
f = figure('Name', 'Interactive Chart');
ax = axes('Parent', f);

% Plot the data
plot(ax, time, pore);
xlabel(ax, 'Time');
ylabel(ax, 'Pore');

% Add buttons to manually set x and y limits
uicontrol('Style', 'pushbutton', 'String', 'Set X/Y Limits', ...
    'Position', [20 60 100 30], 'Callback', @set_limits);

% Initialize draggable lines at the quarter and three-quarter mark
x_limits = xlim(ax);
start_line = line([x_limits(1), x_limits(1)], ylim(ax), 'Color', 'r', 'LineWidth', 2, 'ButtonDownFcn', @start_drag);
end_line = line([x_limits(2), x_limits(2)], ylim(ax), 'Color', 'g', 'LineWidth', 2, 'ButtonDownFcn', @start_drag);

% Variables to save the indices
start_ind = [];
end_ind = [];

% Add a button to save the x limits after adjusting the lines
save_button = uicontrol('Style', 'pushbutton', 'String', 'Save X Limits', ...
    'Position', [20 20 100 30], 'Callback', @save_x_limits);

% Wait for user to finish selecting range and press the save button
uiwait(f);

    function set_limits(~, ~)
        % Allow user to manually set x and y limits
        new_xlims = inputdlg({'Enter new X-Min:', 'Enter new X-Max:'}, ...
            'Change X-Limits', [1 35]);
        if ~isempty(new_xlims)
            new_xmin = str2double(new_xlims{1});
            new_xmax = str2double(new_xlims{2});
            xlim(ax, [new_xmin, new_xmax]);
            % Reposition the start and end lines within the new limits
            set(start_line, 'XData', [new_xmin, new_xmin]);
            set(end_line, 'XData', [new_xmax, new_xmax]);
        end
        new_ylims = inputdlg({'Enter new Y-Min:', 'Enter new Y-Max:'}, ...
            'Change Y-Limits', [1 35]);
        if ~isempty(new_ylims)
            ylim(ax, str2double(new_ylims));
        end
    end


    function start_drag(src, ~)
        % Set up drag and release callbacks
        set(f, 'WindowButtonMotionFcn', @dragging);
        set(f, 'WindowButtonUpFcn', @release_drag);

        function dragging(~, ~)
            % Get current point
            pt = get(ax, 'CurrentPoint');
            set(src, 'XData', [pt(1,1), pt(1,1)]); % Update line position
        end

        function release_drag(~, ~)
            % Remove motion callback
            set(f, 'WindowButtonMotionFcn', '');
            set(f, 'WindowButtonUpFcn', '');

            % Save the final x values
            final_x = get(src, 'XData');
            if src == start_line
                start_ind = find_nearest_index(time, final_x(1));
            elseif src == end_line
                end_ind = find_nearest_index(time, final_x(1));
            end
        end
    end

    function index = find_nearest_index(array, value)
        [~, index] = min(abs(array - value));
    end

    function save_x_limits(~, ~)
        % Get the x positions of the start and end lines
        x_start = get(start_line, 'XData');
        x_end = get(end_line, 'XData');

        % Find the nearest indices in the 'time' array
        strt_ind = find_nearest_index(time, x_start(1));
        end_ind = find_nearest_index(time, x_end(1));

        % Retrieve the corresponding time values
        time_start = time(strt_ind);
        time_end = time(end_ind);

        % Ensure that the indices and time values are different and correct
        if strt_ind == end_ind
            error('Start and end indices are the same. Please adjust the lines and try again.');
        end

        % Downsizing: The same funcion developed for downsizing time-strain is used here:
        new_length = round((2/100) * (end_ind - strt_ind)); % 40% of data is used as the target number of points!
        [time_downs, pore_downs, ind_downs] = fnc_downsize_time_strain_linear(time(strt_ind:end_ind,1), pore(start_ind:end_ind,1), new_length);
        hold on
        plot(time_downs,pore_downs,'Color','red');

        disp(['X Limits saved: Start Index = ', num2str(strt_ind), ', End Index = ', num2str(end_ind)]);
        disp(['Time at Start Index = ', num2str(time_start), ', Time at End Index = ', num2str(time_end)]);
        uiresume(f); % Resume execution after button press
    end
end

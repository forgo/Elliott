%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   FILE: figure_format.m
% AUTHOR: Elliott Richerson
%   DATE: March 4, 2009
%
% DESCRIPTION: This function takes no inputs and formats any figures before
% the 'figure_format' call is invoked.  The formatter will attempt to
% identify the type of plot and automatically locate and format lines,
% axes, labels, title, legend, and surfaces.  This is accomplished
% primarily through testing default property values.  
%
% The 'dcolor' cell array may be altered at will to define the colors taken 
% on by multiple data sets in the same figure.  Similarly, the 'styles' 
% array contains the 'LineStyle' properties taken on by these data sets.  
% Once the limit of specified colors and styles is reached, the 'dcolor' 
% and 'styles' array act as circular buffers, repeating their sequences 
% from the start. The 'string2rgb' function (defined at the bottom of this 
% file) used by dcolor allows a string to be called instead of the RGB 
% array for human readability.  
%
% Universal properties can be set at the end of the function as desired. 
%
% NOTE: It is not recommended to change the properties being tested on as
% unexpected results may occur.  Additionally, it is advised that no
% formatting be done to figures before calling 'figure_format' as it may
% cause the test conditions to become invalid and will override any 
% overlapping formatting changes.  Any properties unspecified to change in 
% 'figure_format' should be called after the invokation; however, unique 
% formatting changes can be made within 'figure_format' as necessary. 
% The point is to avoid formatting clutter in the main code altogether.  
% For example, the extent to which a figure is called in the main code 
% should be as follows:
%
%   figure(1)
%   plot(x,y)
%   hold on;
%   plot(x,y2)
%   title('title');
%   xlabel('x'); 
%   ylabel('y'); 
%   zlabel('z');
%   legend('data 1', 'data 2')
%
%   figure_format
%
% NOTE: If you wish to manually format any plots, any figure calls after 
% 'figure_format' will not have any of the formatting changes.
%
% RELEASE NOTES:
%   - 03/02/2009 - Initial release
%   - 03/04/2009 - Fixed subplot quirks, and made legend location dynamic.
%                  Fixed so that updates are applied in the order that
%                       figures/axes/lines are called. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function figure_format

% Define the Line Colors to be Used in the Order they Will Be Used
%   Requires: length >= 1 (invalid colors will result in help prompt)
dcolor = {string2rgb('RoyalBlue1'),...
          string2rgb('black'),...
          string2rgb('red'),...
          string2rgb('forest green'),...
          string2rgb('goldenrod'),...
          string2rgb('purple'),...
          string2rgb('HotPink1')};

% Define the Line Styles to be Used in the Order they Will Be Used
%   Requires: length >= 1
styles = {'-','--',':','-.'};

% Obtain Screen Dimensions and Define the Pixel Dimensions for Figures
screen_size = get(0,'ScreenSize');
sw = screen_size(3);    % Screen Width
sh = screen_size(4);    % Screen Height
fw = 750;               % Figure Width
fh = 500;               % Figure Height
mh = 90;                % Estimated Menu Height

% Find Existing Figures (in the order they were called) and Loop Through
figures = sort(findobj('MenuBar','figure'));

for F = 1:length(figures)
    
    % Turn the Grid on For Each Figure
    grid on;
    
    % Through Each Iteration, Update which Figure is Current
    set(0,'CurrentFigure',figures(F));
    
    % Position, Size, and Color Figure Appropriately
    set(gcf,'Color',[1 1 1],...
            'Position',[10 (sh-fh-mh)  750 500]);
    
    % In Case of Sub-Plot, Loop Through Axes Children in Order of Calling
    subs = sort(unique(findall(findall(figures(F)),'Type','axes','Tag','')));
    for S = 1:length(subs)
          
        gca = subs(S);
        axis tight; 
        % Ensure the Grid is on For Subplots
        grid(subs(S));

        % Find Plotted Lines in the Order They Were Called
        lines = sort(findobj(gca,'Type','line'));
        
        for L = 1:length(lines)
        
            % Allow Color and Style Sequences to Act as Circular Buffer
            if (L > length(dcolor))
                color_index = mod(L,length(dcolor));
                if (color_index == 0)
                    color_index = length(dcolor);
                end
            else
                color_index = L;
            end
            if (L > length(styles))
                style_index = mod(L,length(styles));
                if (style_index == 0)
                    style_index = length(styles);
                end
            else
                style_index = L;
            end
            
            % Format Each Line, Changing Color and Style
            set(lines(L),  'LineWidth',2,...
                           'Color',cell2mat(dcolor(color_index)),...
                           'LineStyle',styles{style_index});
        end

        % Find all Text Objects Related to Axis Labels and Identify Them
        txtobjs = unique(findall(findall(gcf),'Type','text','Units','data','-not','String',''));
        
        for obj = 1:length(txtobjs)

            % Get Three of the Object's Properties to Adequately Identify It
            Rot = get(txtobjs(obj),'Rotation');
            Hal = get(txtobjs(obj),'HorizontalAlignment');
            Val = get(txtobjs(obj),'VerticalAlignment');

            % Determine the Likely Dimensionality of Plot by Axes Box Mode
            if (strcmp(get(gca,'Box'),'off'))
                dimensionality = 3;
            else
                dimensionality = 2;
            end

            switch dimensionality
                % 2-D Plot Formatting Rules
                case 2
                    % Test if the Current Object is the X-Axis Label
                    if (Rot == 0.0) && (strcmp(Hal,'center')) && (strcmp(Val,'cap'))

                        set(txtobjs(obj),   'Color',[75 75 75]./256,...
                                            'FontName','Century Gothic',...
                                            'FontWeight','bold',...
                                            'FontUnits','pixels',...
                                            'FontSize',16)

                    % Test if the Current Object is the Y-Axis Label
                    elseif (Rot == 90.0) && (strcmp(Hal,'center')) && (strcmp(Val,'bottom'))

                        set(txtobjs(obj),   'Color',[75 75 75]./256,...
                                            'FontName','Century Gothic',...
                                            'FontWeight','bold',...
                                            'FontUnits','pixels',...
                                            'FontSize',16)

                    % Text if the Current Object is the Title
                    elseif (Rot == 0.0) && (strcmp(Hal,'center')) && (strcmp(Val,'bottom'))

                        set(txtobjs(obj),   'Color',[75 75 75]./256,...
                                            'FontName','Century Gothic',...
                                            'FontWeight','bold',...
                                            'FontUnits','pixels',...
                                            'FontSize',18);  

                    % If Conditions Aren't Found, Use Default Text Formatting
                    else

                        set(txtobjs(obj),   'Color',[75 75 75]./256,...
                                            'FontName','Century Gothic',...
                                            'FontWeight','bold',...
                                            'FontUnits','pixels',...
                                            'FontSize',16)

                    end
                % 3-D Plot Formatting Rules
                case 3

                    % Test if the Current Object is the X-Axis Label
                    if (Rot == 0.0) && (strcmp(Hal,'left')) && (strcmp(Val,'top'))

                        set(txtobjs(obj),   'Color',[75 75 75]./256,...
                                            'FontName','Century Gothic',...
                                            'FontWeight','bold',...
                                            'FontUnits','pixels',...
                                            'FontSize',16)

                    % Test if the Current Object is the Y-Axis Label
                    elseif (Rot == 0.0) && (strcmp(Hal,'right')) && (strcmp(Val,'top'))

                        set(txtobjs(obj),   'Color',[75 75 75]./256,...
                                            'FontName','Century Gothic',...
                                            'FontWeight','bold',...
                                            'FontUnits','pixels',...
                                            'FontSize',16)

                    % Test if the Current Object is the Z-Axis Label
                    elseif (Rot == 90.0) && (strcmp(Hal,'center')) && (strcmp(Val,'bottom'))

                        set(txtobjs(obj),   'Color',[75 75 75]./256,...
                                            'FontName','Century Gothic',...
                                            'FontWeight','bold',...
                                            'FontUnits','pixels',...
                                            'FontSize',16)

                    % Text if the Current Object is the Title
                    elseif (Rot == 0.0) && (strcmp(Hal,'center')) && (strcmp(Val,'bottom'))

                        set(txtobjs(obj),   'Color',[75 75 75]./256,...
                                            'FontName','Century Gothic',...
                                            'FontWeight','bold',...
                                            'FontUnits','pixels',...
                                            'FontSize',18);  

                    % If Conditions Aren't Found, Use Default Text Formatting
                    else

                        set(txtobjs(obj),   'Color',[75 75 75]./256,...
                                            'FontName','Century Gothic',...
                                            'FontWeight','bold',...
                                            'FontUnits','pixels',...
                                            'FontSize',16)

                    end

            end


        end

        % Find the Legend and Format Appropriately
        legends = findobj('Tag','legend');
        set(legends,'FontName','Verdana',...
                    'FontWeight','light',...
                    'FontUnits','pixels',...
                    'FontSize',8,...
                    'LineWidth',1.5,...
                    'TextColor',[75 75 75]./256,...
                    'Location','Best'); 

        % Find the Axes / Ticks and Format Appropriately
        set(gca,    'LineWidth',1,...
                    'FontName','Verdana',...
                    'FontUnits','pixels',...
                    'FontSize',13,...
                    'TickDir','in',...
                    'XColor',[75 75 75]./256,...
                    'YColor',[75 75 75]./256,...
                    'TickLength',[0;0]);

        % Find and Set Property Values that Should be Universal

            % Transparify Surface Plots
            set(findobj('FaceAlpha',1.0),'FaceAlpha',1)
        
    end
            
end
    grid on   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    FXN: [rgb] = string2rgb(colorstring)
% AUTHOR: Elliott Richerson
%   DATE: December 23, 2008
%
% DESCRIPTION: This function takes a string input and interprets that
% string as a key to an RGB color array.  The input string must match an
% existing string description listed in the color_store cell array.  If
% not, an error will occur, and a reference table of colors will appear in
% the help browser.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [rgb] = string2rgb(colorstring)

if(~isstr(colorstring))
   error('Input must be a string.'); 
end

color_store = ...
{
'snow',             [255 250 250];
'ghost white',		[248 248 255];
'white smoke',		[245 245 245];
'gainsboro',		[220 220 220];
'floral white',		[255 250 240];
'old lace',			[253 245 230];
'linen',			[250 240 230];
'antique white',	[250 235 215];
'papaya whip',		[255 239 213];
'blanched almond',	[255 235 205];
'bisque',			[255 228 196];
'peach puff',		[255 218 185];
'navajo white',		[255 222 173];
'moccasin',			[255 228 181];
'cornsilk',			[255 248 220];
'ivory',			[255 255 240];
'lemon chiffon',	[255 250 205];
'seashell',			[255 245 238];
'honeydew',			[240 255 240];
'mint cream',		[245 255 250];
'azure',			[240 255 255];
'alice blue',		[240 248 255];
'lavender',			[230 230 250];
'lavender blush',	[255 240 245];
'misty rose',		[255 228 225];
'white',			[255 255 255];
'black',			[0 0 0];
'dark slate gray',	[47 79 79];
'dim gray',			[105 105 105];
'slate gray',		[112 128 144];
'light slate gray',	[119 136 153];
'gray',             [190 190 190];
'midnight blue',	[25 25 112];
'navy',             [0 0 128];
'navy blue',		[0 0 128];
'cornflower blue',	[100 149 237];
'dark slate blue',	[72 61 139];
'slate blue',		[106 90 205];
'medium slate blue',[123 104 238];
'light slate blue',	[132 112 255];
'medium blue',		[0 0 205];
'royal blue',		[65 105 225];
'blue',             [0 0 255];
'dodger blue',		[30 144 255];
'deep sky blue',	[0 191 255];
'sky blue',			[135 206 235];
'light sky blue',	[135 206 250];
'steel blue',		[70 130 180];
'light steel blue',	[176 196 222];
'light blue',		[173 216 230];
'powder blue',		[176 224 230];
'pale turquoise',	[175 238 238];
'dark turquoise',	[0 206 209];
'medium turquoise',	[72 209 204];
'turquoise',		[64 224 208];
'cyan',             [0 255 255];
'light cyan',		[224 255 255];
'cadet blue',		[95 158 160];
'medium aquamarine',[102 205 170];
'aquamarine',		[127 255 212];
'dark green',		[0 100 0];
'dark olive green',	[85 107 47];
'dark sea green',	[143 188 143];
'sea green',		[46 139 87];
'medium sea green',	[60 179 113];
'light sea green',	[32 178 170];
'pale green',		[152 251 152];
'spring green',		[0 255 127];
'lawn green',		[124 252 0];
'green',			[0 255 0];
'chartreuse',		[127 255 0];
'medium spring green',[0 250 154];
'green yellow',		[173 255 47];
'lime green',		[50 205 50];
'yellow green',		[154 205 50];
'forest green',		[34 139 34];
'olive drab',		[107 142 35];
'dark khaki',       [189 183 107];
'khaki',            [240 230 140];
'pale goldenrod',   [238 232 170];
'light goldenrod yellow',[250 250 210];
'light yellow',     [255 255 224];
'yellow',			[255 255 0];
'gold',             [255 215 0];
'light goldenrod',	[238 221 130];
'goldenrod',		[218 165 32];
'dark goldenrod',	[184 134 11];
'rosy brown',		[188 143 143];
'indian red',		[205 92 92];
'saddle brown',		[139 69 19];
'sienna',			[160 82 45];
'peru',             [205 133 63];
'burlywood',		[222 184 135];
'beige',			[245 245 220];
'wheat',			[245 222 179];
'sandy brown',		[244 164 96];
'tan',              [210 180 140];
'chocolate',		[210 105 30];
'firebrick',		[178 34 34];
'brown',			[165 42 42];
'dark salmon',		[233 150 122];
'salmon',			[250 128 114];
'light salmon',		[255 160 122];
'orange',			[255 165 0];
'dark orange',		[255 140 0];
'coral',			[255 127 80];
'light coral',		[240 128 128];
'tomato',			[255 99 71];
'orange red',		[255 69 0];
'red',          	[255 0 0];
'hot pink',			[255 105 180];
'deep pink',		[255 20 147];
'pink',             [255 192 203];
'light pink',		[255 182 193];
'pale violet red',	[219 112 147];
'maroon',			[176 48 96];
'medium violet red',[199 21 133];
'violet red',		[208 32 144];
'magenta',			[255 0 255];
'violet',			[238 130 238];
'plum',             [221 160 221];
'orchid',			[218 112 214];
'medium orchid',	[186 85 211];
'dark orchid',		[153 50 204];
'dark violet',		[148 0 211];
'blue violet',		[138 43 226];
'purple',			[160 32 240];
'medium purple',	[147 112 219];
'thistle',			[216 191 216];
'snow1',			[255 250 250];
'snow2',			[238 233 233];
'snow3',			[205 201 201];
'snow4',			[139 137 137];
'seashell1',		[255 245 238];
'seashell2',		[238 229 222];
'seashell3',		[205 197 191];
'seashell4',		[139 134 130];
'AntiqueWhite1',	[255 239 219];
'AntiqueWhite2',	[238 223 204];
'AntiqueWhite3',	[205 192 176];
'AntiqueWhite4',	[139 131 120];
'bisque1',			[255 228 196];
'bisque2',			[238 213 183];
'bisque3',			[205 183 158];
'bisque4',			[139 125 107];
'PeachPuff1',		[255 218 185];
'PeachPuff2',		[238 203 173];
'PeachPuff3',		[205 175 149];
'PeachPuff4',		[139 119 101];
'NavajoWhite1',		[255 222 173];
'NavajoWhite2',		[238 207 161];
'NavajoWhite3',		[205 179 139];
'NavajoWhite4',		[139 121 94];
'LemonChiffon1',	[255 250 205];
'LemonChiffon2',	[238 233 191];
'LemonChiffon3',	[205 201 165];
'LemonChiffon4',	[139 137 112];
'cornsilk1',		[255 248 220];
'cornsilk2',		[238 232 205];
'cornsilk3',		[205 200 177];
'cornsilk4',		[139 136 120];
'ivory1',			[255 255 240];
'ivory2',			[238 238 224];
'ivory3',			[205 205 193];
'ivory4',			[139 139 131];
'honeydew1',		[240 255 240];
'honeydew2',		[224 238 224];
'honeydew3',		[193 205 193];
'honeydew4',		[131 139 131];
'LavenderBlush1',	[255 240 245];
'LavenderBlush2',	[238 224 229];
'LavenderBlush3',	[205 193 197];
'LavenderBlush4',	[139 131 134];
'MistyRose1',		[255 228 225];
'MistyRose2',		[238 213 210];
'MistyRose3',		[205 183 181];
'MistyRose4',		[139 125 123];
'azure1',			[240 255 255];
'azure2',			[224 238 238];
'azure3',			[193 205 205];
'azure4',			[131 139 139];
'SlateBlue1',		[131 111 255];
'SlateBlue2',		[122 103 238];
'SlateBlue3',		[105 89 205];
'SlateBlue4',		[71 60 139];
'RoyalBlue1',		[72 118 255];
'RoyalBlue2',		[67 110 238];
'RoyalBlue3',		[58 95 205];
'RoyalBlue4',		[39 64 139];
'blue1',			[0 0 255];
'blue2',			[0 0 238];
'blue3',			[0 0 205];
'blue4',			[0 0 139];
'DodgerBlue1',		[30 144 255];
'DodgerBlue2',		[28 134 238];
'DodgerBlue3',		[24 116 205];
'DodgerBlue4',		[16 78 139];
'SteelBlue1',		[99 184 255];
'SteelBlue2',		[92 172 238];
'SteelBlue3',		[79 148 205];
'SteelBlue4',		[54 100 139];
'DeepSkyBlue1',		[0 191 255];
'DeepSkyBlue2',		[0 178 238];
'DeepSkyBlue3',		[0 154 205];
'DeepSkyBlue4',		[0 104 139];
'SkyBlue1',			[135 206 255];
'SkyBlue2',			[126 192 238];
'SkyBlue3',			[108 166 205];
'SkyBlue4',			[74 112 139];
'LightSkyBlue1',	[176 226 255];
'LightSkyBlue2',	[164 211 238];
'LightSkyBlue3',	[141 182 205];
'LightSkyBlue4',	[96 123 139];
'SlateGray1',		[198 226 255];
'SlateGray2',		[185 211 238];
'SlateGray3',		[159 182 205];
'SlateGray4',		[108 123 139];
'LightSteelBlue1',	[202 225 255];
'LightSteelBlue2',	[188 210 238];
'LightSteelBlue3',	[162 181 205];
'LightSteelBlue4',	[110 123 139];
'LightBlue1',		[191 239 255];
'LightBlue2',		[178 223 238];
'LightBlue3',		[154 192 205];
'LightBlue4',		[104 131 139];
'LightCyan1',		[224 255 255];
'LightCyan2',		[209 238 238];
'LightCyan3',		[180 205 205];
'LightCyan4',		[122 139 139];
'PaleTurquoise1',	[187 255 255];
'PaleTurquoise2',	[174 238 238];
'PaleTurquoise3',	[150 205 205];
'PaleTurquoise4',	[102 139 139];
'CadetBlue1',		[152 245 255];
'CadetBlue2',		[142 229 238];
'CadetBlue3',		[122 197 205];
'CadetBlue4',		[83 134 139];
'turquoise1',		[0 245 255];
'turquoise2',		[0 229 238];
'turquoise3',		[0 197 205];
'turquoise4',		[0 134 139];
'cyan1',			[0 255 255];
'cyan2',			[0 238 238];
'cyan3',			[0 205 205];
'cyan4',			[0 139 139];
'DarkSlateGray1',	[151 255 255];
'DarkSlateGray2',	[141 238 238];
'DarkSlateGray3',	[121 205 205];
'DarkSlateGray4',	[82 139 139];
'aquamarine1',		[127 255 212];
'aquamarine2',		[118 238 198];
'aquamarine3',		[102 205 170];
'aquamarine4',		[69 139 116];
'DarkSeaGreen1',	[193 255 193];
'DarkSeaGreen2',	[180 238 180];
'DarkSeaGreen3',	[155 205 155];
'DarkSeaGreen4',	[105 139 105];
'SeaGreen1',		[84 255 159];
'SeaGreen2',		[78 238 148];
'SeaGreen3',		[67 205 128];
'SeaGreen4',		[46 139 87];
'PaleGreen1',		[154 255 154];
'PaleGreen2',		[144 238 144];
'PaleGreen3',		[124 205 124];
'PaleGreen4',		[84 139 84];
'SpringGreen1',		[0 255 127];
'SpringGreen2',		[0 238 118];
'SpringGreen3',		[0 205 102];
'SpringGreen4',		[0 139 69];
'green1',			[0 255 0];
'green2',			[0 238 0];
'green3',			[0 205 0];
'green4',			[0 139 0];
'chartreuse1',		[127 255 0];
'chartreuse2',		[118 238 0];
'chartreuse3',		[102 205 0];
'chartreuse4',		[69 139 0];
'OliveDrab1',		[192 255 62];
'OliveDrab2',		[179 238 58];
'OliveDrab3',		[154 205 50];
'OliveDrab4',		[105 139 34];
'DarkOliveGreen1',	[202 255 112];
'DarkOliveGreen2',	[188 238 104];
'DarkOliveGreen3',	[162 205 90];
'DarkOliveGreen4',	[110 139 61];
'khaki1',			[255 246 143];
'khaki2',			[238 230 133];
'khaki3',			[205 198 115];
'khaki4',			[139 134 78];
'LightGoldenrod1',	[255 236 139];
'LightGoldenrod2',	[238 220 130];
'LightGoldenrod3',	[205 190 112];
'LightGoldenrod4',	[139 129 76];
'LightYellow1',		[255 255 224];
'LightYellow2',		[238 238 209];
'LightYellow3',		[205 205 180];
'LightYellow4',		[139 139 122];
'yellow1',			[255 255 0];
'yellow2',			[238 238 0];
'yellow3',			[205 205 0];
'yellow4',			[139 139 0];
'gold1',			[255 215 0];
'gold2',			[238 201 0];
'gold3',			[205 173 0];
'gold4',			[139 117 0];
'goldenrod1',		[255 193 37];
'goldenrod2',		[238 180 34];
'goldenrod3',		[205 155 29];
'goldenrod4',		[139 105 20];
'DarkGoldenrod1',	[255 185 15];
'DarkGoldenrod2',	[238 173 14];
'DarkGoldenrod3',	[205 149 12];
'DarkGoldenrod4',	[139 101 8];
'RosyBrown1',		[255 193 193];
'RosyBrown2',		[238 180 180];
'RosyBrown3',		[205 155 155];
'RosyBrown4',		[139 105 105];
'IndianRed1',		[255 106 106];
'IndianRed2',		[238 99 99];
'IndianRed3',		[205 85 85];
'IndianRed4',		[139 58 58];
'sienna1',			[255 130 71];
'sienna2',			[238 121 66];
'sienna3',			[205 104 57];
'sienna4',			[139 71 38];
'burlywood1',		[255 211 155];
'burlywood2',		[238 197 145];
'burlywood3',		[205 170 125];
'burlywood4',		[139 115 85];
'wheat1',			[255 231 186];
'wheat2',			[238 216 174];
'wheat3',			[205 186 150];
'wheat4',			[139 126 102];
'tan1',             [255 165 79];
'tan2',             [238 154 73];
'tan3',             [205 133 63];
'tan4',             [139 90 43];
'chocolate1',		[255 127 36];
'chocolate2',		[238 118 33];
'chocolate3',		[205 102 29];
'chocolate4',		[139 69 19];
'firebrick1',		[255 48 48];
'firebrick2',		[238 44 44];
'firebrick3',		[205 38 38];
'firebrick4',		[139 26 26];
'brown1',			[255 64 64];
'brown2',			[238 59 59];
'brown3',			[205 51 51];
'brown4',			[139 35 35];
'salmon1',			[255 140 105];
'salmon2',			[238 130 98];
'salmon3',			[205 112 84];
'salmon4',			[139 76 57];
'LightSalmon1',		[255 160 122];
'LightSalmon2',		[238 149 114];
'LightSalmon3',		[205 129 98];
'LightSalmon4',		[139 87 66];
'orange1',			[255 165 0];
'orange2',			[238 154 0];
'orange3',			[205 133 0];
'orange4',			[139 90 0];
'DarkOrange1',		[255 127 0];
'DarkOrange2',		[238 118 0];
'DarkOrange3',		[205 102 0];
'DarkOrange4',		[139 69 0];
'coral1',			[255 114 86];
'coral2',			[238 106 80];
'coral3',			[205 91 69];
'coral4',			[139 62 47];
'tomato1',			[255 99 71];
'tomato2',			[238 92 66];
'tomato3',			[205 79 57];
'tomato4',			[139 54 38];
'OrangeRed1',		[255 69 0];
'OrangeRed2',		[238 64 0];
'OrangeRed3',		[205 55 0];
'OrangeRed4',		[139 37 0];
'red1',             [255 0 0];
'red2',             [238 0 0];
'red3',             [205 0 0];
'red4',             [139 0 0];
'DeepPink1',		[255 20 147];
'DeepPink2',		[238 18 137];
'DeepPink3',		[205 16 118];
'DeepPink4',		[139 10 80];
'HotPink1',			[255 110 180];
'HotPink2',			[238 106 167];
'HotPink3',			[205 96 144];
'HotPink4',			[139 58 98];
'pink1',			[255 181 197];
'pink2',			[238 169 184];
'pink3',			[205 145 158];
'pink4',			[139 99 108];
'LightPink1',		[255 174 185];
'LightPink2',		[238 162 173];
'LightPink3',		[205 140 149];
'LightPink4',		[139 95 101];
'PaleVioletRed1',	[255 130 171];
'PaleVioletRed2',	[238 121 159];
'PaleVioletRed3',	[205 104 137];
'PaleVioletRed4',	[139 71 93];
'maroon1',			[255 52 179];
'maroon2',			[238 48 167];
'maroon3',			[205 41 144];
'maroon4',			[139 28 98];
'VioletRed1',		[255 62 150];
'VioletRed2',		[238 58 140];
'VioletRed3',		[205 50 120];
'VioletRed4',		[139 34 82];
'magenta1',			[255 0 255];
'magenta2',			[238 0 238];
'magenta3',			[205 0 205];
'magenta4',			[139 0 139];
'orchid1',			[255 131 250];
'orchid2',			[238 122 233];
'orchid3',			[205 105 201];
'orchid4',			[139 71 137];
'plum1',			[255 187 255];
'plum2',			[238 174 238];
'plum3',			[205 150 205];
'plum4',			[139 102 139];
'MediumOrchid1',	[224 102 255];
'MediumOrchid2',	[209 95 238];
'MediumOrchid3',	[180 82 205];
'MediumOrchid4',	[122 55 139];
'DarkOrchid1',		[191 62 255];
'DarkOrchid2',		[178 58 238];
'DarkOrchid3',		[154 50 205];
'DarkOrchid4',		[104 34 139];
'purple1',			[155 48 255];
'purple2',			[145 44 238];
'purple3',			[125 38 205];
'purple4',			[85 26 139];
'MediumPurple1',	[171 130 255];
'MediumPurple2',	[159 121 238];
'MediumPurple3',	[137 104 205];
'MediumPurple4',	[93 71 139];
'thistle1',			[255 225 255];
'thistle2',			[238 210 238];
'thistle3',			[205 181 205];
'thistle4',			[139 123 139];
'dark gray',        [169 169 169];
'medium gray',		[227 227 227];
'light gray',		[242 242 242];
'dark blue',		[0 0 139];
'dark cyan',		[0 139 139];
'dark magenta',		[139 0 139];
'dark red',			[139 0 0];
'light green',		[144 238 144];
};

index = strmatch(colorstring,color_store(:,1),'exact');

if (isempty(index))    
        
    in = sprintf('<p>The input provided to <b><i>string2rgb</i></b>');
    in = sprintf('%s is not valid. Refer to the table below:</p>',in);
    
    html = sprintf('\n<html>\n<body>\n\n%s\n\t<table border="1">\n\t\t',in);

    html = sprintf('%s<tr>\n\t\t\t<td>Label</td>\n\t\t\t',html);
    html = sprintf('%s<td width="250">Visual</td>\n\t\t\t',html);
    html = sprintf('%s<td>R</td>\n\t\t\t',html);  
    html = sprintf('%s<td>G</td>\n\t\t\t',html);
    html = sprintf('%s<td>B</td>\n\t\t</tr>\n\t\t',html);

    for i = 1:length(color_store)

       Name = mat2str(cell2mat(color_store(i,1)));
       RGB = cell2mat(color_store(i,2));

       hex = mat2str(dec2hex(RGB));
       hex = hex(isstrprop(hex,'alphanum'));

       html = sprintf('%s<tr>\n\t\t\t<td>%s</td>\n\t\t\t',html,Name);     
       html = sprintf('%s<td bgcolor="#%s"></td>\n\t\t\t',html,hex);
       html = sprintf('%s<td>%d</td>\n\t\t\t',html,RGB(1));  
       html = sprintf('%s<td>%d</td>\n\t\t\t',html,RGB(2));
       html = sprintf('%s<td>%d</td>\n\t\t</tr>\n\t\t',html,RGB(3));

    end

    html = sprintf('%s</table>\n</body>\n</html>',html);

    web(sprintf('text://%s',html),'-helpbrowser');    
    
    error('''%s'' is not a valid color.',colorstring);
end
    
rgb = cell2mat(color_store(index,2))./256;

end
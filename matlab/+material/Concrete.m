classdef Concrete < Material
    properties (SetAccess = private)
        % Nonnegative numeric scalar (1,1). Maximum compressive stress.
        Compression = nan;
        % Nonnegative numeric scalar (1,1). Cracking stress.
        Cracking = nan;
        % Nonnegative numeric scalar
        Strain_Ultimate = nan;
    end
    
    methods
        function Obj = Concrete(Units, Compression, Strain_Ultimate)
            validateattributes(Units, {'char'}, {'nonempty'}, '', 'Units');
            validateattributes(Compression, {'numeric'}, {'scalar','nonnegative'}, '', 'Compression');
            E = material.Concrete.calculateYoung(Units, Compression);     
            Obj@Material(E);
            Obj.Compression = Compression;
            Obj.Cracking = Obj.calculateCracking(Units, Obj.Compression);
            validateattributes(Strain_Ultimate, {'numeric'}, {'scalar','nonnegative'}, '', 'Strain_Ultimate');
            Obj.Strain_Ultimate = Strain_Ultimate;            
        end
        
        function [Compression] = getCompression(Obj)
            Compression = [Obj(:).Compression];
        end
        
        function [Cracking] = getCracking(Obj)
            Cracking = [Obj(:).Cracking];
        end
        
        function [Strain_Ultimate] = getStrain_Ultimate(Obj)
            Strain_Ultimate = [Obj(:).Strain_Ultimate];
        end
    end
    
    methods (Static)
        function [fr] = calculateCracking(Units, fc)
            if strcmpi(Units, 'MPa')
                fr = 0.62 * sqrt(fc);
            elseif strcmpi(Units, 'kg/cm2')
                fr = 2 * sqrt(fc);
            elseif strcmpi(Units, 'ksi')
                fr = 0.0067 * sqrt(fc*1000);
            else
                error('Concrete:calculateCracking:unknownUnits', 'Units "%s" are unknown', Units);
            end
        end
                
        function [E] = calculateYoung(Units, fc)
            if strcmpi(Units, 'MPa')
                E = 4700 * sqrt(fc);
            elseif strcmpi(Units, 'kg/cm2')
                E = 15100 * sqrt(fc);
            elseif strcmpi(Units, 'ksi')
                E = 57 * sqrt(fc*1000);
            else
                error('Concrete:calculateYoung:unknownUnits', 'Units "%s" are unknown', Units);
            end
        end
    end
end
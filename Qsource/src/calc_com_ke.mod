   -  d   k820309    �          17.0         �.Y                                                                                                           
       calc_com_ke.f90 CALC_COM_KE              CONVERSION_FACTOR FRAMES APA MASKS NMASKS COORDS_MASS PREV_COORDS_MASS VELOCITY REL_COORDS PREV_REL_COORDS RAD_VEC COORDS PREV_COORDS DP_VECT MASS_AVE PREV_MASS_AVE ANG_MOMENTUM EIGEN_STUFF TOT_MASS KE_ROT FIRST_FRAME FRAME_LENGTH                                                     
                                                           
                         @                                'P                    #INCLUDED    #MASK                 �                                                              �                                                                       &                                                             @                                '8                    #MASS    #AVDW    #BVDW 	                �                                              
                �                                                           
  p          p            p                                       �                              	                              
  p          p            p                                        @  @                          
     '@                    #FIRST    #LAST    #RESIDUE_NUMBERING    #SOLUTE1    #SOLUTE2    #EXCL1    #EXCL2    #RESTR1    #RESTR2    #HEAVY1    #HEAVY2    #SYBYL1    #SYBYL2    #NOTFLAG    #SYBYLCODE                 �                                                               �                                                              �                                                              �                                                              �                                                              �                                                              �                                                              �                                                              �                                            	                   �                                    $       
                   �                                    (                          �                                    ,                          �                                    0                          �                                    4                          �                                          8              #         @                                                      #M                                                    P               #MASK_TYPE    #         @                                                      #M                                                    P               #MASK_TYPE    %         @                                                          #MASK                                                    P               #MASK_TYPE    #         @                                                       #M !   #X "   #XMASKED #                                              !     P               #MASK_TYPE                                             "                   
               &                                                                                     #                   	               &                                                                                        $                                                       %            8                        &                                           #IAC_TYPE                                              &                                   &                                                                                        '                                       
               10              @                              (                                	       V	              2390.0574           @  @                              )     
                    p          p 
           p 
                                       @                              *                                                      +                   
                &                                                      @ `@                              ,     
       P              p          p 
           p 
                         #MASK_TYPE              @ @@                              -                              @                           .     '                    #X /   #Y 0   #Z 1   #MASS 2               �                              /                              	            &                                                       �                              0            H                 	            &                                                       �                              1            �                 	            &                                                       �                              2            �                 	            &                                                      @  @                              3     
                     p          p 
           p 
                         #COM_KE_COORD_TYPE .              @  @                              4     
                     p          p 
           p 
                         #COM_KE_COORD_TYPE .                     @                           5     '�                    #X 6   #Y 7   #Z 8               �                              6                              	            &                                                       �                              7            H                 	            &                                                       �                              8            �                 	            &                                                      @  @                              9     
       �              p          p 
           p 
                         #COM_KE_VELOCITY_TYPE 5              @  @                              :     
       �              p          p 
           p 
                         #COM_KE_VELOCITY_TYPE 5              @  @                              ;     
       �              p          p 
           p 
                         #COM_KE_VELOCITY_TYPE 5              @  @                              <            �              p          p 
         p            p 
         p                          #COM_KE_VELOCITY_TYPE 5                     @                           =     'H                    #XYZ >               �                              >                              	            &                                                      @ @@                              ?     
       H              p          p 
           p 
                         #COORD_TYPE =              @  @                              @     
       H              p          p 
           p 
                         #COORD_TYPE =                     @                           A     'H                    #DP B               �                              B                              	            &                                                      @  @                              C     
       H              p          p 
           p 
                         #DP_TYPE A                     @                           D     '                    #X E   #Y F   #Z G                �                               E                	                �                               F               	                �                               G               	              @  @                              H     
                     p          p 
           p 
                         #MASS_AVE_TYPE D              @  @                              I     
                     p          p 
           p 
                         #MASS_AVE_TYPE D              @  @                              J                          p          p 
         p            p 
         p                          #MASS_AVE_TYPE D                     @                           K     '0                    #EVALUE L   #EVECTOR M                �                               L                              	  p          p            p                                       �                               M     	                        	  p          p          p            p          p                                     @  @                              N     
       0              p          p 
           p 
                         #EIGEN_STUFF_TYPE K              @  @                              O     
              	      p          p 
           p 
                                    @  @                              P                   	      p          p 
         p            p 
         p                                    @  @                              Q     
                    p          p 
           p 
                                   @  @                              R     	       #         @                                   S                     #         @                                   T                    #I U                                              U            %         @                                V                           #DESC W             D                                W                     1 #         @                                  X                    #I Y                                              Y            #         @                                   Z                    #I [             
                                  [           #         @                                  \                    #A ]   #R ^   #N _   #MV `             D                                 ]                   
 %    p          p            p                                    D                                 ^                   
 &    p          p            p                                     @                               _                                                       `            #         @                                   a                    #I b                                              b               �   $      fn#fn !   �   �   b   uapp(CALC_COM_KE    �  @   J   CALC_BASE    �  @   J   MASKMANIP $   ;  h       MASK_TYPE+ATOM_MASK -   �  H   a   MASK_TYPE%INCLUDED+ATOM_MASK )   �  �   a   MASK_TYPE%MASK+ATOM_MASK      n       IAC_TYPE+TOPO #   �  H   a   IAC_TYPE%MASS+TOPO #   5  �   a   IAC_TYPE%AVDW+TOPO #   �  �   a   IAC_TYPE%BVDW+TOPO    m       SET+ATOM_MASK $   }  H   a   SET%FIRST+ATOM_MASK #   �  H   a   SET%LAST+ATOM_MASK 0     H   a   SET%RESIDUE_NUMBERING+ATOM_MASK &   U  H   a   SET%SOLUTE1+ATOM_MASK &   �  H   a   SET%SOLUTE2+ATOM_MASK $   �  H   a   SET%EXCL1+ATOM_MASK $   -  H   a   SET%EXCL2+ATOM_MASK %   u  H   a   SET%RESTR1+ATOM_MASK %   �  H   a   SET%RESTR2+ATOM_MASK %   	  H   a   SET%HEAVY1+ATOM_MASK %   M	  H   a   SET%HEAVY2+ATOM_MASK %   �	  H   a   SET%SYBYL1+ATOM_MASK %   �	  H   a   SET%SYBYL2+ATOM_MASK &   %
  H   a   SET%NOTFLAG+ATOM_MASK (   m
  P   a   SET%SYBYLCODE+ATOM_MASK (   �
  O       MASK_FINALIZE+ATOM_MASK *     W   a   MASK_FINALIZE%M+ATOM_MASK *   c  O       MASK_INITIALIZE+ATOM_MASK ,   �  W   a   MASK_INITIALIZE%M+ATOM_MASK )   	  Z       MASKMANIP_MAKE+MASKMANIP .   c  W   a   MASKMANIP_MAKE%MASK+MASKMANIP #   �  c       MASK_GET+ATOM_MASK %     W   a   MASK_GET%M+ATOM_MASK %   t  �   a   MASK_GET%X+ATOM_MASK +      �   a   MASK_GET%XMASKED+ATOM_MASK    �  @       NAT_PRO+TOPO    �  �       IACLIB+TOPO    f  �       IAC+TOPO    �  r       MAX_MASKS "   d  y       CONVERSION_FACTOR    �  �       FRAMES    q  @       APA    �  �       KINETICENERGY    =  �       MASKS    �  @       NMASKS "      o       COM_KE_COORD_TYPE $   �  �   a   COM_KE_COORD_TYPE%X $   #  �   a   COM_KE_COORD_TYPE%Y $   �  �   a   COM_KE_COORD_TYPE%Z '   K  �   a   COM_KE_COORD_TYPE%MASS    �  �       COORDS_MASS !   �  �       PREV_COORDS_MASS %   5  e       COM_KE_VELOCITY_TYPE '   �  �   a   COM_KE_VELOCITY_TYPE%X '   .  �   a   COM_KE_VELOCITY_TYPE%Y '   �  �   a   COM_KE_VELOCITY_TYPE%Z    V  �       VELOCITY      �       REL_COORDS     �  �       PREV_REL_COORDS    `  �       RAD_VEC    .  Y       COORD_TYPE    �  �   a   COORD_TYPE%XYZ      �       COORDS    �  �       PREV_COORDS    c  X       DP_TYPE    �  �   a   DP_TYPE%DP    O  �       DP_VECT    �  e       MASS_AVE_TYPE     U   H   a   MASS_AVE_TYPE%X     �   H   a   MASS_AVE_TYPE%Y     �   H   a   MASS_AVE_TYPE%Z    -!  �       MASS_AVE    �!  �       PREV_MASS_AVE    {"  �       ANG_MOMENTUM !   B#  i       EIGEN_STUFF_TYPE (   �#  �   a   EIGEN_STUFF_TYPE%EVALUE )   G$  �   a   EIGEN_STUFF_TYPE%EVECTOR    %  �       EIGEN_STUFF    �%  �       TOT_MASS    A&  �       KE_ROT    �&  �       FIRST_FRAME    �'  @       FRAME_LENGTH "   �'  H       COM_KE_INITIALIZE     (  O       COM_KE_FINALIZE "   `(  @   a   COM_KE_FINALIZE%I    �(  Z       COM_KE_ADD     �(  L   a   COM_KE_ADD%DESC     F)  O       COM_KE_PUT_MASS "   �)  @   a   COM_KE_PUT_MASS%I    �)  O       COM_KE_CALC    $*  @   a   COM_KE_CALC%I    d*  e       EIGEN    �*  �   a   EIGEN%A    ]+  �   a   EIGEN%R    �+  @   a   EIGEN%N    1,  @   a   EIGEN%MV    q,  O       COM_KE_HEADING !   �,  @   a   COM_KE_HEADING%I 
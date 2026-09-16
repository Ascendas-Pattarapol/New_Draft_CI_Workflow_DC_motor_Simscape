function sl_customization(cm)                          
                                                      % Register custom Model Advisor checks for this folder.
                                                      cm.addModelAdvisorCheckFcn(@defineCust0001SignalNames);
                                                      end                                                    
                                                      
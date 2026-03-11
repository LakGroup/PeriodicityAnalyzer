function settingsCheck = checkSettings(settings1,settings2)

if settings1.contrastPerc == settings2.contrastPerc && settings1.minSizeObject == settings2.minSizeObject && settings1.maxCircularity == settings2.maxCircularity && settings1.numAxons == settings2.numAxons
    settingsCheck = false;
else
    settingsCheck = true;
end
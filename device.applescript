-- source: https://web.archive.org/web/20140716012404/http://daveaddey.com/?p=51
-- https://stackoverflow.com/questions/35469569/how-can-i-programmatically-create-a-multi-output-device-in-os-x

OSStatus CreateAggregateDevice() {

OSStatus osErr = noErr;
UInt32 outSize;
Boolean outWritable;

//-----------------------
// Start to create a new aggregate by getting the base audio hardware plugin
//-----------------------

osErr = AudioHardwareGetPropertyInfo(kAudioHardwarePropertyPlugInForBundleID, &outSize, &outWritable);
if (osErr != noErr) return osErr;

AudioValueTranslation pluginAVT;

CFStringRef inBundleRef = CFSTR("com.apple.audio.CoreAudio");
AudioObjectID pluginID;

pluginAVT.mInputData = &inBundleRef;
pluginAVT.mInputDataSize = sizeof(inBundleRef);
pluginAVT.mOutputData = &pluginID;
pluginAVT.mOutputDataSize = sizeof(pluginID);

osErr = AudioHardwareGetProperty(kAudioHardwarePropertyPlugInForBundleID, &outSize, &pluginAVT);
if (osErr != noErr) return osErr;

//-----------------------
// Create a CFDictionary for our aggregate device
//-----------------------

CFMutableDictionaryRef aggDeviceDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

CFStringRef AggregateDeviceNameRef = CFSTR("Your Aggregate Name");
CFStringRef AggregateDeviceUIDRef = CFSTR("com.yourcompany.yourchoiceofuid");

// add the name of the device to the dictionary
CFDictionaryAddValue(aggDeviceDict, CFSTR(kAudioAggregateDeviceNameKey), AggregateDeviceNameRef);

// add our choice of UID for the aggregate device to the dictionary
CFDictionaryAddValue(aggDeviceDict, CFSTR(kAudioAggregateDeviceUIDKey), AggregateDeviceUIDRef);

//-----------------------
// Create a CFMutableArray for our sub-device list
//-----------------------

// this example assumes that you already know the UID of the device to be added
// you can find this for a given AudioDeviceID via AudioDeviceGetProperty for the kAudioDevicePropertyDeviceUID property
// obviously the example deviceUID below won't actually work!
CFStringRef deviceUID = CFSTR("UIDOfDeviceToBeAdded");

// we need to append the UID for each device to a CFMutableArray, so create one here
CFMutableArrayRef subDevicesArray = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);

// just the one sub-device in this example, so append the sub-device's UID to the CFArray
CFArrayAppendValue(subDevicesArray, deviceUID);

// if you need to add more than one sub-device, then keep calling CFArrayAppendValue here for the other sub-device UIDs

//-----------------------
// Feed the dictionary to the plugin, to create a blank aggregate device
//-----------------------

AudioObjectPropertyAddress pluginAOPA;
pluginAOPA.mSelector = kAudioPlugInCreateAggregateDevice;
pluginAOPA.mScope = kAudioObjectPropertyScopeGlobal;
pluginAOPA.mElement = kAudioObjectPropertyElementMaster;
UInt32 outDataSize;

osErr = AudioObjectGetPropertyDataSize(pluginID, &pluginAOPA, 0, NULL, &outDataSize);
if (osErr != noErr) return osErr;

AudioDeviceID outAggregateDevice;

osErr = AudioObjectGetPropertyData(pluginID, &pluginAOPA, sizeof(aggDeviceDict), &aggDeviceDict, &outDataSize, &outAggregateDevice);
if (osErr != noErr) return osErr;

// pause for a bit to make sure that everything completed correctly
// this is to work around a bug in the HAL where a new aggregate device seems to disappear briefly after it is created
CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false);

//-----------------------
// Set the sub-device list
//-----------------------

pluginAOPA.mSelector = kAudioAggregateDevicePropertyFullSubDeviceList;
pluginAOPA.mScope = kAudioObjectPropertyScopeGlobal;
pluginAOPA.mElement = kAudioObjectPropertyElementMaster;
outDataSize = sizeof(CFMutableArrayRef);
osErr = AudioObjectSetPropertyData(outAggregateDevice, &pluginAOPA, 0, NULL, outDataSize, &subDevicesArray);
if (osErr != noErr) return osErr;

// pause again to give the changes time to take effect
CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false);

//-----------------------
// Set the master device
//-----------------------

// set the master device manually (this is the device which will act as the master clock for the aggregate device)
// pass in the UID of the device you want to use
pluginAOPA.mSelector = kAudioAggregateDevicePropertyMasterSubDevice;
pluginAOPA.mScope = kAudioObjectPropertyScopeGlobal;
pluginAOPA.mElement = kAudioObjectPropertyElementMaster;
outDataSize = sizeof(deviceUID);
osErr = AudioObjectSetPropertyData(outAggregateDevice, &pluginAOPA, 0, NULL, outDataSize, &deviceUID);
if (osErr != noErr) return osErr;

// pause again to give the changes time to take effect
CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false);

//-----------------------
// Clean up
//-----------------------

// release the CF objects we have created - we don't need them any more
CFRelease(aggDeviceDict);
CFRelease(subDevicesArray);

// release the device UID
CFRelease(deviceUID);

return noErr;

}

//go:build linux

package extension

import (
	"fmt"
	"log"
	"strings"
	"github.com/ugorji/go/codec"
)

func (e *Extension) GetOutputNamedPipe(datatype string) string {
	//unimplemented function
	logger.Printf("extensionconfig::GetOutputNamedPipe:: Function is not implemented for Linux")
	return ""
}

func getDataTypeToNamedPipeMapping() (map[string]string, error) {
	//unimplemented function
	logger.Printf("extensionconfig::getDataTypeToNamedPipeMapping:: Function is not implemented for Linux")
	return nil, nil

}

func getExtensionConfigResponse(jsonBytes []byte) (string, error) {
	var data []byte
	enc := codec.NewEncoderBytes(&data, new(codec.MsgpackHandle))
	if err := enc.Encode(string(jsonBytes)); err != nil {
		return "", err
	}
	
	fs := &FluentSocket{}
	fs.sockAddress = "/var/run/mdsd-ci/default_fluent.socket"
	if containerType != "" && strings.Compare(strings.ToLower(containerType), "prometheussidecar") == 0 {
		fs.sockAddress = fmt.Sprintf("/var/run/mdsd-%s/default_fluent.socket", containerType)
	}
	responseBytes, err := FluentSocketWriter.writeAndRead(fs, data)
	defer FluentSocketWriter.disconnect(fs)
	logger.Printf("Info::mdsd::Making call to FluentSocket: %s to write and read the config data", fs.sockAddress)
	if err != nil {
		return "", err
	}
	logger.Printf("extensionconfig::getExtensionConfigResponse:: getting extension config from fluent socket-end")

	response := string(responseBytes) // TODO: why is this converted to a string then back into a []byte?
	return response, nil
}

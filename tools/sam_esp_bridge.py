"""USB serial bridge foundation for SAM-AI and the pocket ESP32.

The bridge is deliberately transport-only: it forwards newline-delimited JSON
control frames and length-prefixed PCM frames between COM5 and a localhost TCP
client. SAM-AI can attach to TCP 8765 without exposing the device to the LAN.
"""
from __future__ import annotations

import argparse
import asyncio
import json
import struct

import serial
from sam_external_audio import ExternalAudio


async def run(port: str, baud: int, tcp_port: int) -> None:
    ser = None
    clients: set[asyncio.StreamWriter] = set()
    audio = ExternalAudio(__import__('pathlib').Path('E:/sam-ai/external_audio'), 3.0, None)

    async def client(reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
        clients.add(writer)
        try:
            while data := await reader.read(65536):
                ser.write(data)
        finally:
            clients.discard(writer)
            writer.close()
            await writer.wait_closed()

    server = await asyncio.start_server(client, "127.0.0.1", tcp_port)
    print(f"SAM ESP bridge: {port} → 127.0.0.1:{tcp_port}")
    try:
        while True:
            if ser is None or not ser.is_open:
                try:
                    ser = serial.Serial(port, baudrate=baud, timeout=0.05)
                    print(f"Reconnected {port} at {baud} baud")
                except serial.SerialException:
                    await asyncio.sleep(1.0)
                    continue
            try:
                data = await asyncio.to_thread(ser.read, 4096)
            except serial.SerialException:
                try:
                    ser.close()
                except Exception:
                    pass
                ser = None
                continue
            if data:
                with open('E:/sam-ai/bridge_rx.log', 'a', encoding='utf-8') as dbg:
                    dbg.write(f'{len(data)} bytes {data[:16].hex()}\n')
                audio.feed(data)
                for writer in tuple(clients):
                    writer.write(data)
                    await writer.drain()
            await asyncio.sleep(0.001)
    finally:
        server.close()
        await server.wait_closed()
        if ser is not None:
            ser.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", default="COM5")
    parser.add_argument("--baud", type=int, default=921600)
    parser.add_argument("--tcp-port", type=int, default=8765)
    args = parser.parse_args()
    asyncio.run(run(args.port, args.baud, args.tcp_port))

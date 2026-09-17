// Host-side tests for lp66.h, not part of the firmware.
//
//   c++ -std=c++17 -Wall -o /tmp/lp66_test tv-lift/lp66_test.cpp && /tmp/lp66_test

#include "lp66.h"

#include <cstdio>

using namespace lp66;

static int failures = 0;

static void expect_hex(const char *name, const std::vector<uint8_t> &actual, const std::string &expected) {
  std::string hex = to_hex(actual);
  if (hex != expected) {
    std::printf("FAIL %s\n  expected: %s\n  actual:   %s\n", name, expected.c_str(), hex.c_str());
    failures++;
  }
}

static void expect(const char *name, bool ok) {
  if (!ok) {
    std::printf("FAIL %s\n", name);
    failures++;
  }
}

static Decoder::Result feed_all(Decoder &decoder, const std::vector<uint8_t> &bytes) {
  Decoder::Result result = Decoder::Result::NONE;
  for (uint8_t b : bytes) {
    Decoder::Result r = decoder.feed(b);
    if (r != Decoder::Result::NONE) result = r;
  }
  return result;
}

int main() {
  const CounterMode H = CounterMode::HIGH_FIRST;

  // Reference frames from the protocol brief, counter 0000
  expect_hex("memory 1", encode_control(CMD_MEMORY_1, 1, 0, H), "FA 17 06 01 00 00 10 FD");
  expect_hex("memory 2", encode_control(CMD_MEMORY_2, 1, 0, H), "FA 17 07 01 00 00 11 FD");
  expect_hex("memory 3", encode_control(CMD_MEMORY_3, 1, 0, H), "FA 17 08 01 00 00 1E FD");
  expect_hex("up start", encode_control(CMD_UP, 1, 0, H), "FA 17 03 01 00 00 15 FD");
  expect_hex("up stop", encode_control(CMD_UP, 0, 0, H), "FA 17 03 00 00 00 14 FD");
  expect_hex("down start", encode_control(CMD_DOWN, 1, 0, H), "FA 17 04 01 00 00 12 FD");
  expect_hex("down stop", encode_control(CMD_DOWN, 0, 0, H), "FA 17 04 00 00 00 13 FD");
  expect_hex("save 1", encode_control(CMD_SAVE_1, 1, 0, H), "FA 17 20 01 00 00 36 FD");
  expect_hex("save 2", encode_control(CMD_SAVE_2, 1, 0, H), "FA 17 21 01 00 00 37 FD");
  expect_hex("save 3", encode_control(CMD_SAVE_3, 1, 0, H), "FA 17 22 01 00 00 34 FD");

  // Counter byte order
  expect_hex("counter high first", encode_control(CMD_MEMORY_1, 1, 0x0102, H), "FA 17 06 01 01 02 13 FD");
  expect_hex("counter low first", encode_control(CMD_MEMORY_1, 1, 0x0102, CounterMode::LOW_FIRST),
             "FA 17 06 01 02 01 13 FD");
  expect_hex("counter zero", encode_control(CMD_MEMORY_1, 1, 0x0102, CounterMode::ZERO), "FA 17 06 01 00 00 10 FD");

  // Escaping: reserved bytes in data and checksum, escape bytes excluded from checksum
  expect_hex("escape FA in counter", encode_control(CMD_MEMORY_1, 1, 0x00FA, H), "FA 17 06 01 00 FE FA EA FD");
  expect_hex("escape FE in counter", encode_control(CMD_MEMORY_1, 1, 0xFE00, H), "FA 17 06 01 FE FE 00 EE FD");
  expect_hex("escape FD checksum", encode_control(CMD_MEMORY_1, 1, 0x00ED, H), "FA 17 06 01 00 ED FE FD FD");

  // Decoder
  {
    Decoder d;
    auto frame = encode_control(CMD_MEMORY_1, 1, 0x00FA, H);
    expect("decode escaped frame", feed_all(d, frame) == Decoder::Result::FRAME);
    expect_hex("decoded payload", d.payload(), "17 06 01 00 FA EA");
    expect_hex("decoded raw", d.raw(), "FA 17 06 01 00 FE FA EA FD");
    expect("decoded id", d.message_id() == ID_CONTROL);
  }
  {
    Decoder d;
    expect("escaped FD checksum", feed_all(d, encode_control(CMD_MEMORY_1, 1, 0x00ED, H)) == Decoder::Result::FRAME);
  }
  {
    Decoder d;
    expect("garbage before frame", feed_all(d, {0x00, 0x12, 0xFD, 0xFA, 0x17, 0x06, 0x01, 0x00, 0x00, 0x10, 0xFD}) ==
                                       Decoder::Result::FRAME);
  }
  {
    Decoder d;
    expect("bad checksum", feed_all(d, {0xFA, 0x17, 0x06, 0x01, 0x00, 0x00, 0x11, 0xFD}) == Decoder::Result::INVALID);
  }
  {
    Decoder d;
    expect("empty frame", feed_all(d, {0xFA, 0xFD}) == Decoder::Result::INVALID);
  }
  {
    Decoder d;
    feed_all(d, {0xFA, 0x17, 0x06});
    expect("restart on new start byte", feed_all(d, encode_control(CMD_UP, 1, 0, H)) == Decoder::Result::FRAME);
    expect_hex("restart payload", d.payload(), "17 03 01 00 00 15");
  }
  {
    Decoder d;
    std::vector<uint8_t> long_frame(Decoder::MAX_FRAME_SIZE + 1, 0x01);
    long_frame[0] = START;
    expect("oversized frame", feed_all(d, long_frame) == Decoder::Result::INVALID);
    expect("frame after oversized", feed_all(d, encode_control(CMD_UP, 0, 0, H)) == Decoder::Result::FRAME);
  }

  if (failures == 0) std::printf("all tests passed\n");
  return failures == 0 ? 0 : 1;
}

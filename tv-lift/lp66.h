#pragma once

// LUMI LP66 serial protocol (Xantron PREMIUM-600HE TV lift).
//
// Frame: FA | ID | data | checksum | FD
// - checksum: XOR over all unescaped bytes between FA and FD
// - FA, FD and FE between start and end byte are prefixed with FE
//
// No ESPHome dependencies, so tv-lift/lp66_test.cpp can test it on the host.

#include <cstdint>
#include <string>
#include <vector>

namespace lp66 {

static const uint8_t START = 0xFA;
static const uint8_t END = 0xFD;
static const uint8_t ESCAPE = 0xFE;

// Message IDs
static const uint8_t ID_SYSTEM_DATA = 0x03;  // CU -> host
static const uint8_t ID_CONTROL = 0x17;      // host -> CU
static const uint8_t ID_SYSTEM_ERROR = 0xA0; // CU -> host

// Control commands (ID_CONTROL), value 0x01 = start, 0x00 = stop
static const uint8_t CMD_RESET = 0x02;
static const uint8_t CMD_UP = 0x03;
static const uint8_t CMD_DOWN = 0x04;
static const uint8_t CMD_MEMORY_1 = 0x06;
static const uint8_t CMD_MEMORY_2 = 0x07;
static const uint8_t CMD_MEMORY_3 = 0x08;
static const uint8_t CMD_SAVE_1 = 0x20;
static const uint8_t CMD_SAVE_2 = 0x21;
static const uint8_t CMD_SAVE_3 = 0x22;

// The protocol document calls the frame counter uint16 without naming the
// byte order. Must match the options of the counter mode select in tv-lift.yaml.
enum class CounterMode : uint8_t {
  HIGH_FIRST = 0,
  LOW_FIRST = 1,
  ZERO = 2,
};

inline uint8_t checksum(const std::vector<uint8_t> &bytes) {
  uint8_t sum = 0;
  for (uint8_t b : bytes) sum ^= b;
  return sum;
}

inline bool is_reserved(uint8_t b) { return b == START || b == END || b == ESCAPE; }

inline void append_counter(std::vector<uint8_t> &payload, uint16_t counter, CounterMode mode) {
  uint8_t high = counter >> 8;
  uint8_t low = counter & 0xFF;
  switch (mode) {
    case CounterMode::LOW_FIRST:
      payload.push_back(low);
      payload.push_back(high);
      break;
    case CounterMode::ZERO:
      payload.push_back(0x00);
      payload.push_back(0x00);
      break;
    default:
      payload.push_back(high);
      payload.push_back(low);
      break;
  }
}

// Wraps an unescaped payload (without checksum) into a complete frame.
inline std::vector<uint8_t> encode_frame(std::vector<uint8_t> payload) {
  payload.push_back(checksum(payload));

  std::vector<uint8_t> frame;
  frame.reserve(payload.size() * 2 + 2);
  frame.push_back(START);
  for (uint8_t b : payload) {
    if (is_reserved(b)) frame.push_back(ESCAPE);
    frame.push_back(b);
  }
  frame.push_back(END);
  return frame;
}

inline std::vector<uint8_t> encode_control(uint8_t command, uint8_t value, uint16_t counter, CounterMode mode) {
  std::vector<uint8_t> payload{ID_CONTROL, command, value};
  append_counter(payload, counter, mode);
  return encode_frame(payload);
}

inline std::string to_hex(const std::vector<uint8_t> &bytes) {
  static const char DIGITS[] = "0123456789ABCDEF";
  std::string out;
  out.reserve(bytes.size() * 3);
  for (uint8_t b : bytes) {
    if (!out.empty()) out.push_back(' ');
    out.push_back(DIGITS[b >> 4]);
    out.push_back(DIGITS[b & 0x0F]);
  }
  return out;
}

// Collects received bytes into frames, undoes escaping and checks the checksum.
// Bytes outside a frame are ignored, a frame cut off by a new start byte is dropped.
class Decoder {
 public:
  enum class Result { NONE, FRAME, INVALID };

  static const size_t MAX_FRAME_SIZE = 64;

  Result feed(uint8_t b) {
    if (b == START && !escaped_) {
      in_frame_ = true;
      raw_.assign(1, b);
      payload_.clear();
      return Result::NONE;
    }
    if (!in_frame_) return Result::NONE;

    raw_.push_back(b);
    if (raw_.size() > MAX_FRAME_SIZE) return finish(Result::INVALID);

    if (escaped_) {
      escaped_ = false;
      payload_.push_back(b);
      return Result::NONE;
    }
    if (b == ESCAPE) {
      escaped_ = true;
      return Result::NONE;
    }
    if (b == END) {
      bool valid = payload_.size() >= 2 &&
                   checksum(std::vector<uint8_t>(payload_.begin(), payload_.end() - 1)) == payload_.back();
      return finish(valid ? Result::FRAME : Result::INVALID);
    }
    payload_.push_back(b);
    return Result::NONE;
  }

  // Frame as received, including start, escape and end bytes.
  const std::vector<uint8_t> &raw() const { return raw_; }

  // Unescaped bytes between start and end byte, including the checksum.
  const std::vector<uint8_t> &payload() const { return payload_; }

  uint8_t message_id() const { return payload_.empty() ? 0 : payload_[0]; }

 private:
  Result finish(Result result) {
    in_frame_ = false;
    escaped_ = false;
    return result;
  }

  bool in_frame_ = false;
  bool escaped_ = false;
  std::vector<uint8_t> raw_;
  std::vector<uint8_t> payload_;
};

inline Decoder &rx_decoder() {
  static Decoder decoder;
  return decoder;
}

}  // namespace lp66

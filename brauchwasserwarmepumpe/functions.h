#pragma once

#include "esphome.h"

constexpr const char* SG_READY_0_TEXT_UNKNOWN = "Unbekannt";
constexpr const char* SG_READY_1_TEXT_SPERRE = "1 - Sperrung"; // (1:0)
constexpr const char* SG_READY_2_TEXT_NORMAL = "2 - Normalbetrieb"; // (0:0)
constexpr const char* SG_READY_3_TEXT_EINSCHALTEMPFEHLUNG = "3 - Einschaltempfehlung"; // (0:1)
constexpr const char* SG_READY_4_TEXT_AKTIVIERUNG = "4 - Aktivierung"; // (1:1)

inline void update_sg_ready_select(esphome::template_::TemplateSelect *select, bool sg1, bool sg2);
inline int get_sg_ready_mode(esphome::switch_::Switch *relay_1, esphome::switch_::Switch *relay_2);
inline void set_sg_ready_mode_by_text(const std::string &value, esphome::switch_::Switch *relay_1, esphome::switch_::Switch *relay_2);
inline std::string get_sg_ready_mode_text(esphome::switch_::Switch *relay_1, esphome::switch_::Switch *relay_2);

inline void update_sg_ready_select(esphome::template_::TemplateSelect *select, esphome::switch_::Switch *relay_1, esphome::switch_::Switch *relay_2) {
    select->publish_state(get_sg_ready_mode_text(relay_1, relay_2));
}

inline void set_sg_ready_mode(const int value, esphome::switch_::Switch *relay_1, esphome::switch_::Switch *relay_2) {
    if (value == 1) { // (1:0)
        relay_1->publish_state(true);
        relay_2->publish_state(false);
    
    } else if (value == 2) { // (0:0)
        relay_1->publish_state(false);
        relay_2->publish_state(false);
    
    } else if (value == 3) { // (0:1)
        relay_1->publish_state(false);
        relay_2->publish_state(true);

    } else if (value == 4) { // (1:1)
        relay_1->publish_state(true);
        relay_2->publish_state(true);

    } else {
        ESP_LOGI("warn", "[set_sg_ready_mode] Unknown value: %d | setting: %s", value, SG_READY_2_TEXT_NORMAL);
        set_sg_ready_mode(2, relay_1, relay_2);
    }
}

inline int get_sg_ready_mode(esphome::switch_::Switch *relay_1, esphome::switch_::Switch *relay_2) {
    if (relay_1->state && !relay_2->state) {
        return 1; // (1:0)
    } else if (!relay_1->state && relay_2->state) {
        return 3; // (0:1)
    } else if (relay_1->state && relay_2->state) {
        return 4;// (1:1)
    } else {
        return 2; // (0:0)
    }
}

inline void set_sg_ready_mode_text(const std::string &value, esphome::switch_::Switch *relay_1, esphome::switch_::Switch *relay_2) {
    if (value == SG_READY_1_TEXT_SPERRE) {
        set_sg_ready_mode(1, relay_1, relay_2);
    
    } else if (value == SG_READY_2_TEXT_NORMAL) {
        set_sg_ready_mode(2, relay_1, relay_2);
    
    } else if (value == SG_READY_3_TEXT_EINSCHALTEMPFEHLUNG) {
        set_sg_ready_mode(3, relay_1, relay_2);

    } else if (value == SG_READY_4_TEXT_AKTIVIERUNG) {
        set_sg_ready_mode(4, relay_1, relay_2);

    } else {
        ESP_LOGI("warn", "[handler] Unbekannter Wert: %s | setze: %s", value.c_str(), SG_READY_1_TEXT_SPERRE);
        set_sg_ready_mode(2, relay_1, relay_2);
    }
}


inline std::string get_sg_ready_mode_text(esphome::switch_::Switch *relay_1, esphome::switch_::Switch *relay_2) {
    int state = get_sg_ready_mode(relay_1, relay_2);

    if (state == 1) {
        return std::string(SG_READY_1_TEXT_SPERRE);

    } else if (state == 2) {
        return std::string(SG_READY_2_TEXT_NORMAL);

    } else if (state == 3) {
        return std::string(SG_READY_3_TEXT_EINSCHALTEMPFEHLUNG);
        
    } else if (state == 4) {
        return std::string(SG_READY_4_TEXT_AKTIVIERUNG);
    }

    return std::string(SG_READY_0_TEXT_UNKNOWN);
}
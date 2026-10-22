
# =========================================================
# FREEDOM IN CODE
# Ambient / Relaxing / Dream-like Musical Composition
# Sonic Pi
#
# Main concept:
# Structure creates order.
# Randomness creates freedom.
#
# This composition combines a fixed harmonic framework
# with controlled randomness in melody, textures,
# dynamics, timing, and stereo positioning.
#
# Total structure: 144 beats at 55 BPM
# Approximate duration: 2 minutes 37 seconds
# =========================================================

use_bpm 55

# ---------------------------------------------------------
# INITIAL SETTINGS
#
# Reset all control variables before each performance.
# This prevents previous playback states from affecting
# the new performance.
# ---------------------------------------------------------

set :section, 1
set :finished, false
set :structure_done, false
set :bar_number, 0
set :chord_index, 0

# Set a different seed to explore different variations.
# The same seed helps make rehearsals reproducible.
use_random_seed 2026


# =========================================================
# SHARED MUSICAL MATERIAL
#
# All harmony-related layers use the same progression.
# This creates consistency between structured and
# randomly generated musical elements.
# =========================================================

define :get_chords do
  [
    chord(:e3, :minor),
    chord(:c3, :major),
    chord(:g3, :major),
    chord(:d3, :sus4)
  ]
end

define :get_chord_tones do
  [
    [:e4, :g4, :b4],
    [:c4, :e4, :g4],
    [:g4, :b4, :d5],
    [:d4, :g4, :a4]
  ]
end

# A recognizable melody is preserved in each chord.
# Small variations are introduced later in the piece.

define :get_melody_phrases do
  [
    [:e4, :fs4, :g4, :b4,
     :a4, :g4, :fs4, :e4],
    
    [:e4, :g4, :a4, :g4,
     :e4, :d4, :e4, :g4],
    
    [:g4, :a4, :b4, :d5,
     :b4, :a4, :g4, :fs4],
    
    [:a4, :g4, :fs4, :e4,
     :d4, :e4, :g4, :a4]
  ]
end

# Gradually reduce sound levels during the outro.
# Section 4 occupies bars 14 to 17.

define :fade_level do |bar|
  if bar < 14
    1.0
  elsif bar == 14
    0.70
  elsif bar == 15
    0.48
  elsif bar == 16
    0.25
  else
    0.10
  end
end


# =========================================================
# 1. AIR / WAVE BACKGROUND
#
# Soft noise creates a spacious atmospheric background.
#
# Controlled randomization changes:
# - Noise texture
# - Filter cutoff
# - Stereo position
#
# The volume rises gently and fades during the outro.
# =========================================================

with_fx :reverb, mix: 0.75, room: 1 do
  
  live_loop :waves do
    
    stop if get(:finished)
    
    section = get(:section)
    bar = get(:bar_number) || 0
    
    if section == 1
      wave_amp = 0.018
      
    elsif section == 2
      wave_amp = 0.027
      
    elsif section == 3
      wave_amp = 0.035
      
    else
      wave_amp = 0.018 * fade_level(bar)
    end
    
    use_synth [:bnoise, :cnoise, :gnoise].choose
    
    play :e3,
      attack: 1.5,
      sustain: 2,
      release: 4,
      cutoff: rrand(65, 95),
      amp: wave_amp,
      pan: rrand(-0.7, 0.7)
    
    sleep 4
    
  end
  
end


# =========================================================
# 2. SOFT HARMONY
#
# The fixed chord progression provides musical order.
#
# Em - C - G - Dsus4
#
# Every chord lasts exactly 8 beats.
# A shared cue synchronizes the other musical layers.
#
# Harmony remains present throughout the composition
# and becomes gradually quieter near the ending.
# =========================================================

with_fx :reverb, mix: 0.75, room: 1 do
  
  live_loop :harmony do
    
    stop if get(:finished)
    
    use_synth :hollow
    
    section = get(:section)
    bar = get(:bar_number) || 0
    
    chord_index = bar % 4
    
    current_chord = get_chords[chord_index]
    
    set :chord_index, chord_index
    
    if section == 1
      harmony_amp = 0.13
      
    elsif section == 2
      harmony_amp = 0.19
      
    elsif section == 3
      harmony_amp = 0.24
      
    else
      harmony_amp = 0.19 * fade_level(bar)
    end
    
    play_chord current_chord,
      attack: 1.5,
      sustain: 3,
      release: 5,
      amp: harmony_amp
    
    # Announce each new harmonic phrase.
    cue :bar_start
    
    set :bar_number, bar + 1
    
    sleep 8
    
  end
  
end


# =========================================================
# 3. MAIN MELODY
#
# The melody follows the harmonic structure.
#
# Each phrase contains 8 notes over 8 beats.
# The main melodic identity is recognizable.
#
# Controlled randomness occasionally substitutes
# a note with a tone from the current chord.
#
# The intro begins with space before the melody enters.
# =========================================================

with_fx :reverb, mix: 0.72, room: 0.9 do
  
  live_loop :melody do
    
    sync :bar_start
    
    stop if get(:finished)
    
    section = get(:section)
    bar = (get(:bar_number) || 1) - 1
    
    chord_index = get(:chord_index) || 0
    
    phrase = get_melody_phrases[chord_index]
    tones = get_chord_tones[chord_index]
    
    # Let the background establish the atmosphere
    # during the first 8 beats.
    
    if bar == 0
      
      sleep 8
      
    else
      
      8.times do |i|
        
        note = phrase[i]
        
        # Occasional variation, but only using
        # notes that fit the current harmony.
        
        if section == 2 && one_in(8)
          note = tones.choose
          
        elsif section == 3 && one_in(5)
          note = tones.choose
        end
        
        if section == 1
          
          use_synth :pretty_bell
          melody_amp = 0.18
          
        elsif section == 2
          
          use_synth :pretty_bell
          melody_amp = 0.26
          
        elsif section == 3
          
          use_synth [:pretty_bell, :hollow].choose
          melody_amp = 0.32
          
        else
          
          use_synth :pretty_bell
          melody_amp = 0.22 * fade_level(bar)
          
        end
        
        # A subtle variation in expression.
        note_amp = melody_amp * rrand(0.90, 1.05)
        
        # Gradually create more space in the outro.
        should_play = true
        
        if section == 4 && one_in(4)
          should_play = false
        end
        
        if should_play
          
          play note,
            attack: 0.15,
            release: 2.8,
            amp: note_amp,
            pan: rrand(-0.3, 0.3)
          
        end
        
        # A stable rhythmic framework ensures that
        # the melody stays aligned with the chords.
        sleep 1
        
      end
      
    end
    
  end
  
end


# =========================================================
# 4. HIGH FLOATING NOTES
#
# Occasional upper-register notes create a dream-like
# feeling and a sense of musical freedom.
#
# Random notes are selected from the current harmony
# instead of an unrelated pitch collection.
#
# Probability increases towards Section 3.
# =========================================================

with_fx :echo, phase: 1.25, decay: 3 do
  
  with_fx :reverb, mix: 0.65 do
    
    live_loop :floating_notes do
      
      stop if get(:finished)
      
      section = get(:section)
      bar = get(:bar_number) || 0
      
      chord_index = get(:chord_index) || 0
      
      chord_tones = get_chord_tones[chord_index]
      
      if section == 1
        chance = 8
        floating_amp = 0.045
        
      elsif section == 2
        chance = 5
        floating_amp = 0.075
        
      elsif section == 3
        chance = 3
        floating_amp = 0.11
        
      else
        chance = 9
        floating_amp = 0.055 * fade_level(bar)
      end
      
      if one_in(chance)
        
        use_synth :pretty_bell
        
        # Shift a chord tone into a higher register.
        selected_note = chord_tones.choose + 12
        
        play selected_note,
          attack: 0.1,
          release: 3,
          amp: floating_amp,
          pan: rrand(-0.8, 0.8)
        
      end
      
      sleep 2
      
    end
    
  end
  
end


# =========================================================
# 5. GUITAR HARMONICS
#
# Soft guitar harmonics add warmth and texture.
#
# The sample plays quietly behind the main melody.
# Random playback rates introduce subtle differences.
#
# The texture becomes slightly richer in Section 3.
# =========================================================

with_fx :reverb, mix: 0.8, room: 1 do
  
  live_loop :guitar_texture do
    
    stop if get(:finished)
    
    section = get(:section)
    bar = get(:bar_number) || 0
    
    if section == 1
      
      guitar_amp = 0.045
      chance = 3
      
    elsif section == 2
      
      guitar_amp = 0.065
      chance = 2
      
    elsif section == 3
      
      guitar_amp = 0.085
      chance = 1
      
    else
      
      guitar_amp = 0.05 * fade_level(bar)
      chance = 3
      
    end
    
    if one_in(chance)
      
      sample :guit_harmonics,
        amp: guitar_amp,
        rate: [0.8, 0.9, 1].choose,
        pan: rrand(-0.5, 0.5)
      
    end
    
    sleep 8
    
  end
  
end


# =========================================================
# 6. GUITAR SLIDE
#
# Guitar slides create a drifting, floating sensation.
#
# Random triggering and stereo movement represent
# unpredictability and freedom.
#
# Slides remain quiet to avoid distracting from melody.
# =========================================================

with_fx :reverb, mix: 0.85, room: 1 do
  
  live_loop :guitar_slide do
    
    stop if get(:finished)
    
    section = get(:section)
    bar = get(:bar_number) || 0
    
    if section == 1
      
      chance = 7
      slide_amp = 0.025
      
    elsif section == 2
      
      chance = 5
      slide_amp = 0.040
      
    elsif section == 3
      
      chance = 4
      slide_amp = 0.055
      
    else
      
      chance = 9
      slide_amp = 0.025 * fade_level(bar)
      
    end
    
    if one_in(chance)
      
      sample :guit_e_slide,
        amp: slide_amp,
        rate: [0.7, 0.8, 0.9].choose,
        pan: rrand(-0.8, 0.8)
      
    end
    
    sleep 4
    
  end
  
end


# =========================================================
# 7. GLASS TEXTURE
#
# Delicate glass sounds create a transparent atmosphere.
#
# Echo and reverb help the sound blend into the music.
#
# Random triggering prevents the texture from becoming
# predictable or repetitive.
# =========================================================

with_fx :echo, phase: 1.5, decay: 4 do
  
  with_fx :reverb, mix: 0.8 do
    
    live_loop :glass_texture do
      
      stop if get(:finished)
      
      section = get(:section)
      bar = get(:bar_number) || 0
      
      if section == 1
        
        chance = 8
        glass_amp = 0.025
        
      elsif section == 2
        
        chance = 5
        glass_amp = 0.035
        
      elsif section == 3
        
        chance = 4
        glass_amp = 0.050
        
      else
        
        chance = 10
        glass_amp = 0.025 * fade_level(bar)
        
      end
      
      if one_in(chance)
        
        sample :ambi_glass_rub,
          amp: glass_amp,
          rate: [0.8, 0.9, 1].choose,
          pan: rrand(-0.7, 0.7)
        
      end
      
      sleep 4
      
    end
    
  end
  
end


# =========================================================
# 8. DEEP FOUNDATION
#
# Soft bass notes support the chord progression.
#
# The bass uses the same harmonic synchronization cue
# as the main melody.
#
# This ensures that low notes match the current chord.
# =========================================================

with_fx :reverb, mix: 0.6 do
  
  live_loop :deep_notes do
    
    sync :bar_start
    
    stop if get(:finished)
    
    use_synth :dark_ambience
    
    section = get(:section)
    bar = (get(:bar_number) || 1) - 1
    
    bass_notes = [:e2, :c2, :g2, :d2]
    
    chord_index = get(:chord_index) || 0
    
    note = bass_notes[chord_index]
    
    if section == 1
      bass_amp = 0.045
      
    elsif section == 2
      bass_amp = 0.065
      
    elsif section == 3
      bass_amp = 0.085
      
    else
      bass_amp = 0.055 * fade_level(bar)
    end
    
    play note,
      attack: 1.5,
      sustain: 3,
      release: 4,
      amp: bass_amp
    
  end
  
end


# =========================================================
# 9. LIGHT ELECTRONIC PULSE
#
# A subtle electronic pulse adds gentle movement.
#
# The pulse is absent during the intro and outro.
# It becomes more active during Sections 2 and 3.
#
# Random omission makes the pulse feel less mechanical.
# =========================================================

live_loop :soft_pulse do
  
  stop if get(:finished)
  
  section = get(:section)
  
  if section == 2
    
    if one_in(2)
      
      sample :elec_tick,
        amp: 0.018,
        pan: rrand(-0.3, 0.3)
      
    end
    
  elsif section == 3
    
    if one_in(2)
      
      sample :elec_tick,
        amp: 0.025,
        pan: rrand(-0.5, 0.5)
      
    end
    
  end
  
  sleep 2
  
end


# =========================================================
# 10. COMPOSITION STRUCTURE
#
# Four sections define the overall musical journey.
#
# INTRO       32 beats
# DEVELOPMENT 40 beats
# FLOATING    40 beats
# OUTRO       32 beats
#
# Total: 144 beats
#
# The piece develops from simplicity to richness,
# before gradually returning to silence.
# =========================================================

live_loop :structure do
  
  stop if get(:structure_done)
  
  
  # -------------------------------------------------------
  # SECTION 1 - INTRO
  #
  # The composition begins with a quiet atmosphere.
  # Background sounds and harmony introduce the mood.
  # The melody enters after the first harmonic phrase.
  # -------------------------------------------------------
  
  set :section, 1
  
  puts "SECTION 1 - INTRO"
  
  sleep 32
  
  
  # -------------------------------------------------------
  # SECTION 2 - DEVELOPMENT
  #
  # The melody grows stronger.
  # More textures become active.
  # Small random variations appear.
  # -------------------------------------------------------
  
  set :section, 2
  
  puts "SECTION 2 - DEVELOPMENT"
  
  sleep 40
  
  
  # -------------------------------------------------------
  # SECTION 3 - FLOATING
  #
  # The music reaches its richest point.
  # Controlled random notes create freedom.
  # Layers interact without losing harmonic structure.
  # -------------------------------------------------------
  
  set :section, 3
  
  puts "SECTION 3 - FLOATING"
  
  sleep 40
  
  
  # -------------------------------------------------------
  # SECTION 4 - OUTRO
  #
  # The electronic pulse disappears.
  # The melody becomes more spacious.
  # The remaining textures gradually become quieter.
  #
  # The music slowly returns to silence.
  # -------------------------------------------------------
  
  set :section, 4
  
  puts "SECTION 4 - OUTRO"
  
  sleep 32
  
  
  # -------------------------------------------------------
  # END
  #
  # Stop all composition loops.
  # Existing reverb and release tails decay naturally.
  # -------------------------------------------------------
  
  set :finished, true
  set :structure_done, true
  
  puts "END - FREEDOM IN CODE"
  
  stop
  
end
